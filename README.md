Spiffy Stores API
=================

The SpiffyStores API gem allows Ruby developers to programmatically access the admin section of SpiffyStores stores.

The API is implemented as JSON over HTTP using all four verbs (GET/POST/PUT/DELETE). Each resource, like Order, Product, or Collection, has its own URL and is manipulated in isolation. In other words, we’ve tried to make the API follow the REST principles as much as possible.

## Usage

### Requirements

All API usage happens through SpiffyStores applications, created by either shop owners for their own shops, or by SpiffyStores Partners for use by other shop owners:

* Shop owners can create applications for themselves through their own admin: https://docs.spiffy_stores.com/api/authentication/creating-a-private-app
* SpiffyStores Partners create applications through their admin: http://app.spiffy_stores.com/services/partners

For more information and detailed documentation about the API visit http://api.spiffy_stores.com

#### Ruby version

This gem requires Ruby 2.3.1 as of version 4.3. If you need to use an older Ruby version then update your `Gemfile` to lock onto an older release than 4.3.

### Installation

Add `spiffy_stores_api` to your `Gemfile`:

```ruby
gem 'spiffy_stores_api'
```

Or install via [gem](http://rubygems.org/)

```bash
gem install spiffy_stores_api
```

### Getting Started

SpiffyStoresAPI uses ActiveResource to communicate with the REST web service. ActiveResource has to be configured with a fully authorized URL of a particular store first. To obtain that URL you can follow these steps:

1. First create a new application in either the partners admin or your store admin. For a private App you'll need the API_KEY and the PASSWORD otherwise you'll need the API_KEY and SHARED_SECRET.

   If you're not sure how to create a new application in the partner/store admin and/or if you're not sure how to generate the required credentials, you can [read the related spiffy_stores docs](https://docs.spiffy_stores.com/api/guides/api-credentials) on the same.

2. For a private App you just need to set the base site url as follows:

   ```ruby
   shop_url = "https://#{API_KEY}:#{PASSWORD}@SHOP_NAME.spiffystores.com/api"
   SpiffyStoresAPI::Base.site = shop_url
   ```

   That's it, you're done, skip to step 6 and start using the API!

   For a partner app you will need to supply two parameters to the Session class before you instantiate it:

  ```ruby
  SpiffyStoresAPI::Session.setup({:api_key => API_KEY, :secret => SHARED_SECRET})
  ```

   Spiffy Stores maintains [`omniauth-spiffy-oauth2`](https://github.com/SpiffyStores/omniauth-spiffy-oauth2) which securely wraps the OAuth flow and interactions with Spiffy Stores (steps 3 and 4 above). Using this gem is the recommended way to use OAuth authentication in your application.

3. In order to access a shop's data, apps need an access token from that specific shop. This is a two-stage process. Before interacting with a shop for the first time an app should redirect the user to the following URL:

   ```
   GET https://SHOP_NAME.spiffystores.com/api/oauth/authorize
   ```

   with the following parameters:

   * ``client_id``– Required – The API key for your app
   * ``scope`` – Required – The list of required scopes (explained here: http://docs.spiffy_stores.com/api/tutorials/oauth)
   * ``redirect_uri`` – Required – The URL where you want to redirect the users after they authorize the client. The complete URL specified here must be identical to one of the Application Redirect URLs set in the App's section of the Partners dashboard. Note: in older applications, this parameter was optional, and redirected to the Application Callback URL when no other value was specified.
   * ``state`` – Optional – A randomly selected value provided by your application, which is unique for each authorization request. During the OAuth callback phase, your application must check that this value matches the one you provided during authorization. [This mechanism is important for the security of your application](https://tools.ietf.org/html/rfc6819#section-3.6).

   We've added the create_permission_url method to make this easier, first instantiate your session object:

   ```ruby
   session = SpiffyStoresAPI::Session.new("SHOP_NAME.spiffystores.com")
   ```

   Then call:

   ```ruby
   scope = ["write_products"]
   permission_url = session.create_permission_url(scope)
   ```

   or if you want a custom redirect_uri:

   ```ruby
   permission_url = session.create_permission_url(scope, "https://my_redirect_uri.com")
   ```

4. Once authorized, the shop redirects the owner to the return URL of your application with a parameter named 'code'. This is a temporary token that the app can exchange for a permanent access token.

   Before you proceed, make sure your application performs the following security checks. If any of the checks fails, your application must reject the request with an error, and must not proceed further.

   * Ensure the provided ``state`` is the same one that your application provided to SpiffyStores during Step 3.
   * Ensure the provided hmac is valid. The hmac is signed by SpiffyStores as explained below, in the Verification section.
   * Ensure the provided hostname parameter is a valid hostname, ends with myspiffy_stores.com, and does not contain characters other than letters (a-z), numbers (0-9), dots, and hyphens.

   If all security checks pass, the authorization code can be exchanged once for a permanent access token. The exchange is made with a request to the shop.

   ```
   POST https://SHOP_NAME.spiffystores.com/api/oauth/token
   ```

   with the following parameters:

   * ``client_id`` – Required – The API key for your app
   * ``client_secret`` – Required – The shared secret for your app
   * ``code`` – Required – The token you received in step 3

   and you'll get your permanent access token back in the response.

   There is a method to make the request and get the token for you. Pass
   all the params received from the previous call and the method will verify
   the params, extract the temp code and then request your token:

   ```ruby
   token = session.request_token(params)
   ```

   This method will save the token to the session object and return it. For future sessions simply pass the token in when creating the session object:

   ```ruby
   session = SpiffyStoresAPI::Session.new("SHOP_NAME.spiffystores.com", token)
   ```

5. The session must be activated before use:

   ```ruby
   SpiffyStoresAPI::Base.activate_session(session)
   ```

6. Now you're ready to make authorized API requests to your shop! Data is returned as ActiveResource instances:

   ```ruby
   shop = SpiffyStoresAPI::Store.current

   # Get a specific product
   product = SpiffyStoresAPI::Product.find(179761209)

   # Create a new product
   new_product = SpiffyStoresAPI::Product.new
   new_product.title = "Burton Custom Freestlye 151"
   new_product.product_type = "Snowboard"
   new_product.vendor = "Burton"
   new_product.save

   # Update a product
   product.handle = "burton-snowboard"
   product.save
   ```

   Alternatively, you can use #temp to initialize a Session and execute a command which also handles temporarily setting ActiveResource::Base.site:

   ```ruby
   products = SpiffyStoresAPI::Session.temp("SHOP_NAME.spiffystores.com", token) { SpiffyStoresAPI::Product.find(:all) }
   ```

7. If you want to work with another shop, you'll first need to clear the session:

   ```ruby
   SpiffyStoresAPI::Base.clear_session
   ```


### Console

This package also supports the ``spiffy_stores-cli`` executable to make it easy to open up an interactive console to use the API with a shop.

1. Install the ``spiffy_stores_cli`` gem.

```bash
gem install spiffy_stores_cli
```

2. Obtain a private API key and password to use with your shop (step 2 in "Getting Started")

3. Use the ``spiffy_stores-cli`` script to save the credentials for the shop to quickly log in.

   ```bash
   spiffy_stores-cli add yourshopname
   ```

   Follow the prompts for the shop domain, API key and password.

4. Start the console for the connection.

   ```bash
   spiffy_stores-cli console
   ```

5. To see the full list of commands, type:

   ```bash
   spiffy_stores-cli help
   ```

## Threadsafety

ActiveResource is threadsafe as of version 4.1 (which works with Rails 4.x and above).

If you were previously using SpiffyStores's [activeresource fork](https://github.com/spiffy_stores/activeresource) then you should remove it and use ActiveResource 4.1.

## Using Development Version

Download the source code and run:

```bash
rake install
```

## Additional Resources

API Docs: http://docs.spiffy_stores.com/api

Ask questions on the forums: http://ecommerce.spiffy_stores.com/c/spiffy_stores-apis-and-technology

## Copyright

Copyright (c) 2016 Spiffy Stores. See LICENSE for details.
