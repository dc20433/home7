require 'prawn'
require 'prawn/table'

class PatientDirectoryPdf < Prawn::Document
  def initialize(registrations, title_modifier)
    # A4 Portrait is perfect for the directory table width (margins: 30pt on each side)
    super(page_size: 'A4', page_layout: :portrait, margin: 30)
    @registrations = registrations
    @title_modifier = title_modifier
    
    setup_fonts
    header
    directory_table
    footer
  end

  def setup_fonts
    # Load system Noto Sans CJK to render Chinese patient names cleanly
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
    text "Patient Directory Report: #{@title_modifier}", size: 12, align: :center, color: "444444"
    text "Generated on: #{Time.now.strftime('%B %d, %Y at %I:%M %p')} | Total Registrations: #{@registrations.count}", size: 9, align: :center, color: "666666"
    move_down 15
    stroke_horizontal_rule
    move_down 15
  end

  def directory_table
    # Table headers exactly match the original clinical directory layout
    table_data = [["Last Name", "First Name", "M.I.", "D.O.B.", "Age", "Gender", "Created On", "Status"]]
    
    @registrations.each do |r|
      table_data << [
        r.last_name.to_s,
        r.first_name.to_s,
        r.init.to_s,
        r.dob.to_s,
        r.p_age.to_s,
        r.gender.to_s,
        r.created_at&.to_date.to_s,
        r.onboarding_status.to_s
      ]
    end

    # Total width of A4 Portrait is 595.28 points. Minus margins (30 + 30) = 535.28 bounds.width.
    # Column widths mathematically sum exactly to 535.28:
    # 100 + 100 + 25 + 75 + 30 + 45 + 85 + 75.28 = 535.28
    table(table_data, header: true, width: bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = 'EAEAEA'
      row(0).size = 9
      
      columns(0).width = 100     # Last Name
      columns(1).width = 100     # First Name
      columns(2).width = 25      # M.I.
      columns(3).width = 75      # D.O.B.
      columns(4).width = 30      # Age
      columns(5).width = 45      # Gender
      columns(6).width = 85      # Created On
      columns(7).width = 75.28   # Onboarding Status

      cells.size = 8
      cells.border_width = 0.5
      cells.border_color = 'CCCCCC'
      cells.padding = 5
      
      self.row_colors = ['FFFFFF', 'F9F9F9']
      self.header = true
    end
  end

  def footer
    page_count.times do |i|
      go_to_page(i + 1)
      draw_text "Page #{i + 1} of #{page_count}", at: [bounds.right - 70, -10], size: 8, color: "666666"
      draw_text "CONFIDENTIAL DIRECTORY - INTERNAL AUDITING ONLY", at: [0, -10], size: 8, color: "888888"
    end
  end
end