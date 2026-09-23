# Install the Hackathon site on your environment

This hackathon was built using MkDocs markdown, and it is required to convert Markdown to HTML.

To install this Hackathon site on your environment you need to follow these steps:
1. Install a Webserver such as NGINX.
2. Create the Web pages using `make build-insiders`.
3. Create a Symlink between the MKdocs HTML `site`folder and the root folder of your HTTP server.
4. Access the URL. Depending on your environment you may need to check firewall rules and permissions.


## Install NGINX


NGINX install example
```bash
sudo dnf install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
```

Firewall configuration
You may need to add firewall rules and check permissions. Ensure you use the proper user.
```bash
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```




## Create the Web pages

To create the Web pages (Converting Markdown to HTML) run command bellow.  
Note1: It is assumed that you have cloned the repo already with: `git clone <url-do-repo>`.  
Note2: This will create a folder `site` with all static pages. 


```bash
cd ~/DCFPartnerHackathon/ && git pull && make build-insiders
```

Output
```bash
$ cd ~/DCFPartnerHackathon/
nokia@g21:~/DCFPartnerHackathon$ make build-insiders 
docker run -v $(pwd):/docs --entrypoint mkdocs ghcr.io/eda-labs/mkdocs-material:v9.7.5-2 build --clean --strict

 │  ⚠  Warning from the Material for MkDocs team
 │
 │  MkDocs 2.0, the underlying framework of Material for MkDocs,
 │  will introduce backward-incompatible changes, including:
 │
 │  × All plugins will stop working – the plugin system has been removed
 │  × All theme overrides will break – the theming system has been rewritten
 │  × No migration path exists – existing projects cannot be upgraded
 │  × Closed contribution model – community members can't report bugs
 │  × Currently unlicensed – unsuitable for production use
 │
 │  Our full analysis:
 │
 │  https://squidfunk.github.io/mkdocs-material/blog/2026/02/18/mkdocs-2.0/

INFO    -  [macros] - WARNING: YAML configuration file was not found! /docs/macros/vars.yml
INFO    -  [macros] - Found local Python module 'macros/main' in: /docs
INFO    -  [macros] - Found external Python module 'macros/main' in: /docs
INFO    -  [macros] - Functions found: define_env,on_pre_page_macros,on_post_page_macros,on_post_build
INFO    -  [macros] - Includes directory: macros
INFO    -  [macros] - Found j2 variable 'block_start_string': '-{{%'
INFO    -  [macros] - Found j2 variable 'block_end_string': '%}}-'
INFO    -  [macros] - Found j2 variable 'variable_start_string': '-{{'
INFO    -  [macros] - Found j2 variable 'variable_end_string': '}}-'
INFO    -  [macros] - Config variables: ['extra', 'config', 'environment', 'plugin', 'git', 'social', 'tags', 'annotate', 'macros', 'filters', 'filters_builtin']
INFO    -  [macros] - Config macros: ['context', 'macros_info', 'now', 'fix_url', 'diagram', 'video', 'youtube', 'image']
INFO    -  [macros] - Config filters: ['pretty', 'relative_url']
INFO    -  Cleaning site directory
INFO    -  Building documentation to directory: /docs/site
INFO    -  Doc file 'index.md' contains an absolute link '/clab/README.md', it was left as is.
INFO    -  Doc file 'index.md' contains an absolute link '/eda/README.md', it was left as is.
INFO    -  Doc file 'index.md' contains an absolute link '/clab/README.md', it was left as is.
INFO    -  Doc file 'index.md' contains an absolute link '/eda/README.md', it was left as is.
INFO    -  Documentation built in 22.54 seconds
nokia@g21:~/DCFPartnerHackathon$ 
```





## Create the symlink

The previous step created a folder `site` with all static pages.  
To make it easier to update the site you should create a symlink between this folder and the webserver root folder. 
Example to create the symlink (You need to verify the website root folder in your installation).  
```bash
    chown -R ${username}:${username} /var/www/DCFPartnerHackathon
    sudo ln -s /home/nokia/DCFPartnerHackathon/site /usr/share/nginx/html/
```




## Access the URL

Access the URL using the IP or Name. 

```bash
http://<SERVER_IP>
```

> [!WARNING]
> Depending on your environment you may need to check firewall rules and permissions.



## Update your site

With this approach, if you need to update the website you just need to execute the following command:

```bash
cd ~/DCFPartnerHackathon/ && git pull && make build-insiders
```




