# YB94

[yb94.name](https://yb94.name)

양북94 계모임을 위한 사이트



### Screenshots

-----------------

<div>
  <img width="200" src="https://user-images.githubusercontent.com/29008142/87246800-812d9300-c48a-11ea-9cd3-2b8756df9ace.png">
  <img width="200" src="https://user-images.githubusercontent.com/29008142/87246818-9f938e80-c48a-11ea-812f-0bce9799d60f.png">
  <img width="200" src="https://user-images.githubusercontent.com/29008142/87246821-a3bfac00-c48a-11ea-99d3-cab5ff15f45d.png">
  <img width="200" src="https://user-images.githubusercontent.com/29008142/87246822-a5896f80-c48a-11ea-8f92-155864e0f44a.png">
  <img width="200" src="https://user-images.githubusercontent.com/29008142/87246825-a7ebc980-c48a-11ea-869e-570b8cbaa8be.png">
  <img width="200" src="https://user-images.githubusercontent.com/29008142/87246827-a91cf680-c48a-11ea-8d61-5f98ba9bc23e.png">
</div>



## Install

### Clone the repository

```shell
git clone https://github.com/jeongminkyo/94YB.git
cd 94YB
```



### Check Ruby version

```shell
ruby -v
```

The ouput should start with something like `ruby 2.2.4`

If not, install the right ruby version using [rbenv](https://github.com/rbenv/rbenv) (it could take a while):

```shell
rbenv install 2.2.4
```



### Install dependencies

Using [Bundler](https://github.com/bundler/bundler)

```shell
bundle install
```



### Set environment variables

Using [Figaro](https://github.com/laserlemon/figaro):

See [config/application.yml.sample](https://github.com/juliendargelos/project/blob/master/config/application.yml.sample) and contact the developer: [contact@juliendargelos.com](mailto:contact@juliendargelos.com) (sensitive data).



### Initialize the database

```shell
rails db:create db:migrate db:seed
```



## Serve

```shell
rails s
```

