require "test_helper"

class Settings::HostingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:family_admin)
  end

  test "cannot edit when self hosting is disabled" do
    get settings_hosting_url
    assert :not_found

    patch settings_hosting_url, params: { setting: { render_deploy_hook: "https://example.com" } }
    assert :not_found
  end
  test "should get edit when self hosting is enabled" do
    with_self_hosting do
      get settings_hosting_url
      assert_response :success
    end
  end

  test "can update settings when self hosting is enabled" do
    with_self_hosting do
      NEW_RENDER_DEPLOY_HOOK = "https://api.render.com/deploy/srv-abc123"
      assert_nil Setting.render_deploy_hook

      patch settings_hosting_url, params: { setting: { render_deploy_hook: NEW_RENDER_DEPLOY_HOOK } }

      assert_equal NEW_RENDER_DEPLOY_HOOK, Setting.render_deploy_hook
    end
  end

  test "cannot set auto upgrades mode without a deploy hook" do
    with_self_hosting do
      patch settings_hosting_url, params: { setting: { upgrades_mode: "auto" } }
      assert_response :unprocessable_entity
    end
  end

  test "can choose auto upgrades mode with a deploy hook" do
    with_self_hosting do
      NEW_RENDER_DEPLOY_HOOK = "https://api.render.com/deploy/srv-abc123"
      assert_nil Setting.render_deploy_hook

      patch settings_hosting_url, params: { setting: { render_deploy_hook: NEW_RENDER_DEPLOY_HOOK, upgrades_mode: "release" } }

      assert_equal "auto", Setting.upgrades_mode
      assert_equal "release", Setting.upgrades_target
      assert_equal NEW_RENDER_DEPLOY_HOOK, Setting.render_deploy_hook
    end
  end
end
