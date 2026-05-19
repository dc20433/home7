require 'prawn'
require 'prawn/table'

class OverviewsPdf < Prawn::Document
  def initialize(patients, title_modifier)
    # Standard landscape layout is essential to fit SOAP records horizontally on a single page
    super(page_size: 'A4', page_layout: :landscape, margin: [30, 30, 30, 30])
    @patients = patients
    @title_modifier = title_modifier
    
    setup_fonts
    header
    chart_table
    footer
  end

  def setup_fonts
    # Ensure system Noto Sans CJK is loaded to render Chinese characters cleanly
    font_path = "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"
    if File.exist?(font_path)
      font_families.update("NotoSans" => { normal: font_path, bold: font_path })
      font "NotoSans"
    else
      font "Helvetica"
    end
  end

  def header
    text "Zhang's Acupuncture, Inc.", size: 16, style: :bold, align: :center
    text "Clinical Audit Report: #{@title_modifier}", size: 12, align: :center, color: "444444"
    text "Generated on: #{Time.now.strftime('%B %d, %Y at %I:%M %p')} | Total Records: #{@patients.count}", size: 9, align: :center, color: "666666"
    move_down 15
    stroke_horizontal_rule
    move_down 15
  end

  def chart_table
    # Table Header mapping to typical clinical SOAP charts
    table_data = [["Date", "Patient Name", "Subjective (Complaint)", "Objective/Assessment", "Treatment Plan"]]
    
    @patients.each do |p|
      table_data << [
        p.v_date.to_s,
        "#{p.regi&.name}\n(#{p.regi&.age}y / #{p.regi&.sex})",
        p.com1.to_s,
        "O: #{p.com2}\nA: #{p.diag_given}",
        p.com3.to_s
      ]
    end

    # Layout constraints for standard A4 Landscape (width: ~780pt)
    table(table_data, header: true, width: bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = 'EAEAEA'
      row(0).size = 10
      
      columns(0).width = 70   # Date
      columns(1).width = 110  # Name Info
      columns(2).width = 200  # Subjective
      columns(3).width = 200  # Objective & Assessment
      columns(4).width = 200  # Plan

      # Set small readable font size for clinical blocks
      cells.size = 8
      cells.border_width = 0.5
      cells.border_color = 'CCCCCC'
      cells.padding = 6
      
      self.row_colors = ['FFFFFF', 'F9F9F9']
      self.header = true
    end
  end

  def footer
    page_count.times do |i|
      go_to_page(i + 1)
      # Position absolute footer at bottom right corner
      draw_text "Page #{i + 1} of #{page_count}", 
                at: [bounds.right - 70, -10], 
                size: 8, 
                color: "666666"
      draw_text "CONFIDENTIAL CLINICAL RECORD - FOR INTERNAL AUDITING ONLY", 
                at: [0, -10], 
                size: 8, 
                color: "888888"
    end
  end
end