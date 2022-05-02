defmodule Swoosh.GalleryTest do
  use ExUnit.Case
  use Plug.Test

  describe "previews/0" do
    test "returns the list of previews" do
      assert previews = Support.Gallery.previews()

      assert [
               %{
                 preview_details: %{
                   description: "Sends instructions on how to reset password",
                   tags: [passwords: "yes"],
                   title: "Reset Password"
                 },
                 path: "/reset_password",
                 email_mfa: {Support.Emails.ResetPasswordEmail, :preview, []}
               },
               %{
                 preview_details: %{
                   description: "Sends a warm welcome to the user",
                   tags: [attachments: "yes"],
                   title: "Welcome"
                 },
                 path: "/welcome",
                 email_mfa: {Support.Emails.WelcomeEmail, :preview, []}
               }
             ] == previews
    end
  end

  alias Support.Router

  Router.init([])

  describe "Gallery plug" do
    test "lists preview titles" do
      response = Router.call(conn(:get, "/gallery"), [])
      assert response.status == 200
      assert response.resp_body =~ "Reset Password"
      assert response.resp_body =~ "Welcome"
    end

    test "has links to the previews" do
      response = Router.call(conn(:get, "/gallery"), [])
      assert response.status == 200
      assert response.resp_body =~ "a href=\"/gallery/reset_password\""
      assert response.resp_body =~ "a href=\"/gallery/welcome\""
    end

    test "accessing a preview lists the basic informations" do
      response = Router.call(conn(:get, "/gallery/welcome"), [])
      assert response.status == 200
      assert response.resp_body =~ "Welcome"
      assert response.resp_body =~ "Sends a warm welcome to the user"
      assert response.resp_body =~ "attachments: yes"
    end

    test "accessing a preview shows the email as text" do
      response = Router.call(conn(:get, "/gallery/reset_password"), [])
      assert response.status == 200
      assert response.resp_body =~ "Reset Password"
      assert response.resp_body =~ "Sends instructions on how to reset password"
      assert response.resp_body =~ "passwords: yes"
      assert response.resp_body =~ "Please, reset your password: http://reset.pw"
    end

    test "accessing a preview.html shows the email as html" do
      response = Router.call(conn(:get, "/gallery/reset_password/preview.html"), [])
      assert response.status == 200

      assert response.resp_body ==
               "Please, reset your password <a href=\"http://reset.pw\">here</a>."
    end
  end
end