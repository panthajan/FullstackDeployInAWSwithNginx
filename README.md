# FullstackDeployInAWSwithNginx

Requirement: 

ধরেন আপনার কাছে তিনটা সারভার আছে AWS এ। দুইটা সারভার পাবলিক সাবনেটে একটা প্রাইভেট সাবনেটে। যে সারভারটা প্রাইভেট সাবনেটে আছে সেটাতে আপনি postgres কনফিগার করলেন। আর পাবলিক সাবনেটের একটা সারভারে nginx ডেপ্লয় করলেন Docker দিয়ে। আরেকটা সারভারে দুইটা কন্টেইনার আছে। একটা হলো ফ্রন্টএন্ড কন্টেইনার ( React) আর আরেকটা হলো ব্যাকেন্ড কন্টেইনার (python অথবা node)। আপনাকে কিভাবে nginx কনফিগ লিখতে হবে যাতে করে কেউ http://students.poridhi.com এই URL এ রিকোয়েস্ট পাঠালে ফ্রন্ডএন্ড কন্টেইনারে যায়। http://api.students.poridhi.com এই URL খুজলে Backend কন্টেইনারে যাবে।


Proposed Solution: 

Assuming we have three servers in AWS with two public subnets and one private subnet:

    Public Subnet 1:
        Subnet ID: subnet-1 (example)
        IP Range: 10.0.1.0/24
        Available IP Addresses: 10.0.1.0 - 10.0.1.255
        Assign this subnet to the EC2 instance running Nginx.
        Ngnix EC2 IP: 10.0.1.5/24

    Public Subnet 2:
        Subnet ID: subnet-2 (example)
        IP Range: 10.0.2.0/24
        Available IP Addresses: 10.0.2.0 - 10.0.2.255
        Assign this subnet to an EC2 instance for other purposes.
        Node EC2 IP: 10.0.2.5/24

    Private Subnet:
        Subnet ID: subnet-3 (example)
        IP Range: 10.0.3.0/24
        Available IP Addresses: 10.0.3.0 - 10.0.3.255
        Assign this subnet to the EC2 instance running PostgreSQL.
        DB EC2 IP: 10.0.3.5/24

For the DNS configuration, we need to work on our domain registrar's DNS settings, we need to create A records pointing to the Elastic IP addresses or the public IP addresses of your instances. Here's an example:

    students.poridhi.com A record points to the Elastic IP of the Nginx server in the first public subnet.
    api.students.poridhi.com A record points to the Elastic IP of the same Nginx server in the first public subnet.

Here's the Nginx configuration and steps based on the scenario:

**Nginx Configuration:**

Create separate Nginx configuration files for each site in the `/etc/nginx/sites-available` directory. Use the following example configurations:

**/etc/nginx/sites-available/students.poridhi.com** for the frontend site:

```nginx
server {
    listen 80;
    server_name students.poridhi.com;

    location / {
        proxy_pass http://10.0.2.5:3000;
    }
}
```

**/etc/nginx/sites-available/api.students.poridhi.com** for the backend site:

```nginx
server {
    listen 80;
    server_name api.students.poridhi.com;

    location / {
        proxy_pass http://10.0.2.5:5000;
    }
}
```

## Replace `<frontend_container_port>` and `<backend_container_port>` with the actual ports that your frontend and backend containers are listening on.

**Main Nginx Configuration:**

Edit the main Nginx configuration file, typically located at `/etc/nginx/nginx.conf` or `/etc/nginx/sites-available/default`. Include the site-specific configuration files like this:

```nginx
include /etc/nginx/sites-available/students.poridhi.com;
include /etc/nginx/sites-available/api.students.poridhi.com;
```

**Enable Sites:**

Create symbolic links from the site-specific configuration files in the `sites-available` directory to the `sites-enabled` directory:

```bash
ln -s /etc/nginx/sites-available/students.poridhi.com /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/api.students.poridhi.com /etc/nginx/sites-enabled/
```

**Restart Nginx:**

Finally, restart Nginx to apply the configuration changes:

```bash
sudo service nginx restart
```

This configuration will route requests to `students.poridhi.com` and `api.students.poridhi.com` to the corresponding containers running on the Frontend & backend Container. 
