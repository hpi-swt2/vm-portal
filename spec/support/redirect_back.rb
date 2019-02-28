# frozen_string_literal: true

# Use this module to test whether a controller correctly uses redirect_back
# For example, we could test whether a controller uses redirect_back in its destroy action like this:
#
#   from 'my_url'
#   delete :destroy, params: { id: my_model.to_param }
#   expect(response).to redirect_to('my_url')
# 

module RedirectBack
  def from(url)
    request.env['HTTP_REFERER'] = url
  end
end
