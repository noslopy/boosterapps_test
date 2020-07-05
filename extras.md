Local Testing of other Shopify Apps:

 a) Go to your discounted apps directory

 b) Add new environment variable to application.yml:
```
  BA_TEST_URL: http://localhost:3000/api/
```
 c) Start ngrok to proxy requests:
 ```
  ./ngrok http 3000 -subdomain=dis
  ```
 d) Start discounted app server:
  ```
  foreman start -f Procfile.dev
   ```


5. Now you can go to discout admin open an Offer and schedule a new test
 by clicking "Live Test": https://cl.ly/4598c5f37d29

6. Additionally to be able to upload screenshots to S3 you will need to
add AWS_SECRET_ACCESS_KEY and AWS_ACCESS_KEY_ID variables to application.yml