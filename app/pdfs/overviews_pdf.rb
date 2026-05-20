require 'prawn'
require 'prawn/table'

class OverviewsPdf < Prawn::Document
  def initialize(charts, title_modifier)
    # Landscapes fit standard CJK SOAP logs horizontally without squeezing
    super(page_size: 'A4', page_layout: :landscape, margin: 30)
    @charts = charts
    @title_modifier = title_modifier
    
    setup_fonts
    header
    chart_table
    footer
  end

  def setup_fonts
    # Absolute path to load Noto Sans CJK for rendering Chinese patient names and records
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
    text "Generated on: #{Time.now.strftime('%B %d, %Y at %I:%M %p')} | Total Records: #{@charts.count}", size: 9, align: :center, color: "666666"
    move_down 15
    stroke_horizontal_rule
    move_down 15
  end

  def chart_table
    # Formulated specifically for the Chart SOAP model schema
    table_data = [["Date", "Patient Name", "Subjective (Complaint)", "Objective", "Assessment", "Plan"]]
    
    @charts.each do |c|
      table_data << [
        c.t_date.to_s,
        "#{c.regi&.p_name}\n(#{c.regi&.p_age})",
        c.subj.to_s,
        c.obj.to_s,
        c.assess.to_s,
        c.plan.to_s
      ]
    end

    # Total width of A4 Landscape is 841.89. Minus margins (30 + 30) = 781.89 bounds.width
    # Explicit column widths now sum exactly to 781.89:
    # 70 + 110 + 150 + 150 + 150 + 151.89 = 781.89
    table(table_data, header: true, width: bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = 'EAEAEA'
      row(0).size = 10
      
      columns(0).width = 70     # Date
      columns(1).width = 110    # Patient Name (Age)
      columns(2).width = 150    # Subjective
      columns(3).width = 150    # Objective
      columns(4).width = 150    # Assessment
      columns(5).width = 151.89 # Plan

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
      draw_text "CONFIDENTIAL CLINICAL DATA - FOR AUDIT PURPOSES ONLY", at: [0, -10], size: 8, color: "888888"
    end
  end
end