server {
    listen 80;
    server_name api.students.poridhi.com;

    location / {
        proxy_pass http://10.0.2.5:5000;
    }
}