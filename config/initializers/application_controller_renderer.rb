require 'action_controller/metal/renderers'
require 'oj'

ActionController.add_renderer :yb do |obj, params|
  status_code = params[:response_code] || params[:status] || 200
  result = {}

  if status_code.to_i / 100 == 2 || status_code.to_i / 100 == 3
    result = obj if obj.present?
  else
    if params[:error]
      result = { :code => params[:error][:code], :message => params[:error][:message] }
    end
  end

  self.status = status_code
  self.response_body = Oj.dump(result, { indent: 0, mode: :compat })
end