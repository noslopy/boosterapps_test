### What does this app do?

This app will try to simulate real user's work inside Chrome browser with our apps
 and will create reports and screenshots

### Setup

* rvm use 2.5.6@ba_test --create
* gem install bundler && bundle install
* You don't need any database instances yet to run the app

#### Chrome Driver setup

Here are the steps that have to be done to run the app locally:
1. You will need to install Google Chrome vs Chrome Driver.

   Here is how you can do it on Ubuntu 16.04(tested):
   `https://gist.github.com/ziadoz/3e8ab7e944d02fe872c3454d17af31a5`

   Here is how you can do it on Mac(not tested):
   `https://www.kenst.com/2015/03/installing-chromedriver-on-mac-osx/`

2. Now to run the app you can just start a normal Rails server on port 3000:
   `rails s -p 3000`

3. Ba_test app is using Sidekiq workers to execute it's browser tests so you will
need a local Redis server also


------------


### A small example

```
params = {
  "shopify_domain" => "booster-apps.myshopify.com", "test_method" => "check_xfbml_rendered?",
  "url" => "https://booster-apps.myshopify.com/products/booster-apps-tee"
}
TestWorker.new.perform(params)
```

Logs will show

```
Prepare for tests
Test started
Test done #={"presence"=>true, "test_steps"=>{"xfbml_attribute_rendered"=>true, "messenger_checkbox_action_present"=>true}, "tested_at"=>2020-07-04 09:39:01 -0700, "error_msg"=>nil}
SET_RESULTS={"presence"=>true, "test_steps"=>{"xfbml_attribute_rendered"=>true, "messenger_checkbox_action_present"=>true}, "tested_at"=>2020-07-04 09:39:01 -0700, "error_msg"=>nil}
```


---------------

### App Testing:

This is outside the scope of any trial project tasks :)

[Read more](https://github.com/stuartchaney/ba_test/blob/master/extras.md)


### Additional Notes

You can see exactly what is happening with test browser by setting ':chrome' as driver
for CapybaraTestManager instance:
https://github.com/stuartchaney/ba_test/blob/97cb3dc7af0f7ab9d557e424badd2c5ab65d86c6/app/controllers/api_controller.rb#L8
* This way when a test will start you will see a true Chrome window and you can monitor actions that are happening inside
Browser.

At this point mobile testing is simulated only by setting small window size but
we will have possibility to do true mobile testing when we move our server outside Heroku(most likely to Amazon)

