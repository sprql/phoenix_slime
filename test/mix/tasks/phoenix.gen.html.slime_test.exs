Code.require_file "../mix_helper.exs", __DIR__

defmodule PhoenixSlime.DupHTMLController do
end

defmodule PhoenixSlime.DupHTMLView do
end

defmodule Mix.Tasks.Phoenix.Gen.Html.SlimeTest do
  use ExUnit.Case
  import MixHelper

  setup do
    Mix.Task.clear
    :ok
  end

  test "generates html resource" do
    in_tmp "generates html resource", fn ->
      Mix.Tasks.Phoenix.Gen.Html.Slime.run ["user", "users", "name", "age:integer", "height:decimal",
                                      "nicks:array:text", "famous:boolean", "born_at:naive_datetime",
                                      "secret:uuid", "first_login:date", "alarm:time",
                                      "address_id:references:addresses"]

      assert_file "web/models/user.ex"
      assert_file "test/models/user_test.exs"
      assert [_] = Path.wildcard("priv/repo/migrations/*_create_user.exs")

      assert_file "web/controllers/user_controller.ex", fn file ->
        assert file =~ "defmodule PhoenixSlime.UserController"
        assert file =~ "use PhoenixSlime.Web, :controller"
        assert file =~ "Repo.get!"
      end

      assert_file "web/views/user_view.ex", fn file ->
        assert file =~ "defmodule PhoenixSlime.UserView do"
        assert file =~ "use PhoenixSlime.Web, :view"
      end

      assert_file "web/templates/user/edit.html.slim", fn file ->
        assert file =~ "action: user_path(@conn, :update, @user)"
      end

      assert_file "web/templates/user/form.html.slim", fn file ->
        assert file =~ ~s(= text_input f, :name, class: "form-control")
        assert file =~ ~s(= number_input f, :age, class: "form-control")
        assert file =~ ~s(= number_input f, :height, step: "any", class: "form-control")
        assert file =~ ~s(= checkbox f, :famous, class: "form-control")
        assert file =~ ~s(= datetime_select f, :born_at, class: "form-control")
        assert file =~ ~s(= text_input f, :secret, class: "form-control")
        assert file =~ ~s(= label f, :name, class: "control-label")
        assert file =~ ~s(= label f, :age, class: "control-label")
        assert file =~ ~s(= label f, :height, class: "control-label")
        assert file =~ ~s(= label f, :famous, class: "control-label")
        assert file =~ ~s(= label f, :born_at, class: "control-label")
        assert file =~ ~s(= label f, :secret, class: "control-label")

        refute file =~ ~s(= label f, :address_id)
        refute file =~ ~s(= number_input f, :address_id)
        refute file =~ ":nicks"
      end

      assert_file "web/templates/user/index.html.slim", fn file ->
        assert file =~ "th Name"
        assert file =~ "= for user <- @users do"
        assert file =~ "td= user.name"
      end

      assert_file "web/templates/user/new.html.slim", fn file ->
        assert file =~ "action: user_path(@conn, :create)"
      end

      assert_file "web/templates/user/show.html.slim", fn file ->
        assert file =~ "strong Name:"
        assert file =~ "= @user.name"
      end

      assert_file "test/controllers/user_controller_test.exs", fn file ->
        assert file =~ "defmodule PhoenixSlime.UserControllerTest"
        assert file =~ "use PhoenixSlime.ConnCase"

        assert file =~ ~S|@valid_attrs %{age: 42|
        assert file =~ ~S|@invalid_attrs %{}|
        refute file =~ ~S|address_id: nil|

        assert file =~ ~S|test "lists all entries on index"|
        assert file =~ ~S|conn = get conn, user_path(conn, :index)|
        assert file =~ ~S|assert html_response(conn, 200) =~ "Listing users"|

        assert file =~ ~S|test "renders form for new resources"|
        assert file =~ ~S|conn = get conn, user_path(conn, :new)|
        assert file =~ ~S|assert html_response(conn, 200) =~ "New user"|

        assert file =~ ~S|test "creates resource and redirects when data is valid"|
        assert file =~ ~S|conn = post conn, user_path(conn, :create), user: @valid_attrs|
        assert file =~ ~S|assert redirected_to(conn) == user_path(conn, :index)|
        assert file =~ ~r/creates.*when data is valid.*?assert Repo\.get_by\(User, @valid_attrs\).*?end/s

        assert file =~ ~S|test "does not create resource and renders errors when data is invalid"|
        assert file =~ ~S|conn = post conn, user_path(conn, :create), user: @invalid_attrs|

        assert file =~ ~S|test "shows chosen resource"|
        assert file =~ ~S|user = Repo.insert! %User{}|
        assert file =~ ~S|assert html_response(conn, 200) =~ "Show user"|

        assert file =~ ~S|test "renders form for editing chosen resource"|
        assert file =~ ~S|assert html_response(conn, 200) =~ "Edit user"|

        assert file =~ ~S|test "updates chosen resource and redirects when data is valid"|
        assert file =~ ~S|conn = put conn, user_path(conn, :update, user), user: @valid_attrs|
        assert file =~ ~r/updates.*when data is valid.*?assert Repo\.get_by\(User, @valid_attrs\).*?end/s

        assert file =~ ~S|test "does not update chosen resource and renders errors when data is invalid"|
        assert file =~ ~S|conn = put conn, user_path(conn, :update, user), user: @invalid_attrs|

        assert file =~ ~S|test "deletes chosen resource"|
        assert file =~ ~S|conn = delete conn, user_path(conn, :delete, user)|
      end

      assert_received {:mix_shell, :info, ["\nAdd the resource" <> _ = message]}
      assert message =~ ~s(resources "/users", UserController)
    end
  end

  test "generates nested resource" do
    in_tmp "generates nested resource", fn ->
      Mix.Tasks.Phoenix.Gen.Html.Slime.run ["Admin.SuperUser", "super_users", "name:string"]

      assert_file "web/models/admin/super_user.ex"
      assert [_] = Path.wildcard("priv/repo/migrations/*_create_admin_super_user.exs")

      assert_file "web/controllers/admin/super_user_controller.ex", fn file ->
        assert file =~ "defmodule PhoenixSlime.Admin.SuperUserController"
        assert file =~ "use PhoenixSlime.Web, :controller"
        assert file =~ "Repo.get!"
      end

      assert_file "web/views/admin/super_user_view.ex", fn file ->
        assert file =~ "defmodule PhoenixSlime.Admin.SuperUserView do"
        assert file =~ "use PhoenixSlime.Web, :view"
      end

      assert_file "web/templates/admin/super_user/edit.html.slim", fn file ->
        assert file =~ "h2 Edit super user"
        assert file =~ "action: super_user_path(@conn, :update, @super_user)"
      end

      assert_file "web/templates/admin/super_user/form.html.slim", fn file ->
        assert file =~ ~s(= text_input f, :name, class: "form-control")
      end

      assert_file "web/templates/admin/super_user/index.html.slim", fn file ->
        assert file =~ "h2 Listing super users"
        assert file =~ "th Name"
        assert file =~ "= for super_user <- @super_users do"
      end

      assert_file "web/templates/admin/super_user/new.html.slim", fn file ->
        assert file =~ "h2 New super user"
        assert file =~ "action: super_user_path(@conn, :create)"
      end

      assert_file "web/templates/admin/super_user/show.html.slim", fn file ->
        assert file =~ "h2 Show super user"
        assert file =~ "strong Name:"
        assert file =~ "= @super_user.name"
      end

      assert_file "test/controllers/admin/super_user_controller_test.exs", fn file ->
        assert file =~ ~S|assert html_response(conn, 200) =~ "Listing super users"|
        assert file =~ ~S|assert html_response(conn, 200) =~ "New super user"|
        assert file =~ ~S|assert html_response(conn, 200) =~ "Show super user"|
        assert file =~ ~S|assert html_response(conn, 200) =~ "Edit super user"|
      end

      assert_received {:mix_shell, :info, ["\nAdd the resource" <> _ = message]}
      assert message =~ ~s(resources "/admin/super_users", Admin.SuperUserController)
    end
  end

  test "generates html resource without model" do
    in_tmp "generates html resource without model", fn ->
      Mix.Tasks.Phoenix.Gen.Html.Slime.run ["Admin.User", "users", "--no-model", "name:string"]

      refute File.exists? "web/models/admin/user.ex"
      assert [] = Path.wildcard("priv/repo/migrations/*_create_admin_user.exs")

      assert_file "web/templates/admin/user/form.html.slim", fn file ->
        refute file =~ ~s(--no-model)
      end
    end
  end

  test "plural can't contain a colon" do
    assert_raise Mix.Error, fn ->
      Mix.Tasks.Phoenix.Gen.Html.Slime.run ["Admin.User", "name:string", "foo:string"]
    end
  end

  test "plural can't have uppercased characters or camelized format" do
    assert_raise Mix.Error, fn ->
      Mix.Tasks.Phoenix.Gen.Html.Slime.run ["Admin.User", "Users", "foo:string"]
    end

    assert_raise Mix.Error, fn ->
      Mix.Tasks.Phoenix.Gen.Html.Slime.run ["Admin.User", "AdminUsers", "foo:string"]
    end
  end

  test "name is already defined" do
    assert_raise Mix.Error, fn ->
      Mix.Tasks.Phoenix.Gen.Html.Slime.run ["DupHTML", "duphtmls"]
    end
  end
end
