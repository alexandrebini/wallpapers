module Admin::ApplicationHelper
  def header(header)
    content_for(:header){ header }
  end
end