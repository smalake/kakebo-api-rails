class UserMailer < ApplicationMailer
  def auth_mail
    email = params[:email]
    @auth_code = params[:auth_code]
    mail(to: email, subject: "【使いやすい家計簿】認証コード")
  end
end
