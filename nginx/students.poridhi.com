server {
    listen 80;
    server_name students.poridhi.com;

    location / {
        proxy_pass http://10.0.2.5:3000;
    }
}