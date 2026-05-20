require 'prawn'
require 'prawn/table'

class PatientRecordPdf < Prawn::Document
  def initialize(patient)
    # A4 Portrait for standard physical files
    super(page_size: 'A4', margin: [30, 40, 30, 40])
    @patient = patient
    @regi = patient.regi
    
    setup_fonts
    header
    render_form_data
    render_health_history
    footer
  end

  def setup_fonts
    font_path = "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"
    if File.exist?(font_path)
      font_families.update("NotoSans" => { normal: font_path, bold: font_path })
      font "NotoSans"
    else
      font "Helvetica"
    end
  end

  def header
    text "Zhang's Acupuncture", size: 18, style: :bold, align: :center
    text "Patient Information Record", size: 14, align: :center, color: "333333"
    text "#{@regi.p_name} | Age: #{@regi.p_age} | Sex: #{@regi.gender}", size: 10, align: :center, color: "666666"
    move_down 15
    stroke_horizontal_rule
    move_down 15
  end

  def render_form_data
    # 1 & 2. Demographics & Contact
    data = [
      ["Updated on:", @patient.v_date.to_s, "Street:", @patient.street],
      ["City:", @patient.city, "State:", @patient.state, "Zip:", @patient.zip],
      ["Cell Phone:", @patient.cell, "Home Phone:", @patient.home],
      ["Work Phone:", @patient.work, "Email:", @patient.email]
    ]
    render_table_section("1 & 2. Demographics & Contact", data)

    # 3. Physicals
    data = [
      ["Height:", @patient.height, "Weight:", @patient.weight, "Marital:", @patient.m_stat],
      ["Occupation:", @patient.occup, "Company:", @patient.company, "Referred:", @patient.referred]
    ]
    render_table_section("3. Physicals & Occupation", data)

    # 4. Patient Concerns
    data = [
      ["Complaint 1:", @patient.com1],
      ["Complaint 2:", @patient.com2],
      ["Complaint 3:", @patient.com3]
    ]
    render_table_section("4. Patient Concerns", data)

    # 6. Case Details
    data = [
      ["Onset Date:", @patient.d_onset.to_s, "Pain Scale:", "#{@patient.pain_scale}/10"],
      ["Prior Acupuncture?:", @patient.aq_b4, "Diagnoses Given:", @patient.diag_given]
    ]
    render_table_section("6. Case Details", data)
  end

  def render_health_history
    move_down 5
    text "5. Major Health History", size: 11, style: :bold
    move_down 5
    issues = @patient.di_list&.reject(&:blank?)&.join(", ") || "None reported"
    text issues, size: 9, leading: 2
    move_down 15

    # 7. Specific Health Data
    data = [
      ["Other Issues:", @patient.o_dis],
      ["Last Period:", @patient.last_prd.to_s, "Pregnant:", @patient.preg, "Weeks:", @patient.preg_wks.to_s]
    ]
    render_table_section("7. Additional Health Data", data)
  end

  def render_table_section(title, data)
    text title, size: 11, style: :bold
    move_down 5
    table(data, width: bounds.width, cell_style: { border_width: 0.5, size: 9, padding: 5 }) do
      cells.border_color = "CCCCCC"
      column(0).font_style = :bold
      column(2).font_style = :bold if data[0].length > 2
    end
    move_down 10
  end

  def footer
    move_down 30
    if @patient.signature.present?
      text "Digitally Signed by Patient", size: 9, style: :italic, align: :right
    else
      move_down 30
      stroke_horizontal_line bounds.right - 180, bounds.right, at: cursor
      text "Physician/Patient Signature", size: 8, align: :right
    end
    
    number_pages "Printed: #{Time.now.strftime('%Y-%m-%d')} - Page <page>", 
                 { at: [0, 0], size: 8, align: :center }
  end
end