class UserMailer < ApplicationMailer
  def auth_mail
    email = params[:email]
    @auth_code = params[:auth_code]
    mail(to: email, subject: "【使いやすい家計簿】認証コード")
  end

  def contact
    @email = params[:email]
    @name = params[:name]
    @description = params[:description]
    mail(to: ENV["CONTACT_MAIL"], subject: "【使いやすい家計簿】お問い合わせ")
  end
end
