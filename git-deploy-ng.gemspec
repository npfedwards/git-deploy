# encoding: utf-8
Gem::Specification.new do |gem|
  gem.name    = 'git-deploy-ng'
  gem.version = '0.8.0'
  gem.executables = %w[ git-deploy ]

  gem.add_dependency 'thor', '~> 1.3'
  gem.add_dependency 'net-ssh', '~> 7.0'
  gem.add_dependency 'net-scp', '~> 4.0'
  gem.add_dependency 'logger'
  gem.required_ruby_version = '>= 2.7'

  gem.summary = "Simple git push-based application deployment"
  gem.description = "A community continuation of mislav/git-deploy. Push-based, Heroku-like deployment over SSH."

  gem.authors  = ['Nathan Edwards', 'Mislav Marohnić']
  gem.email    = 'npfedwards@gmail.com'
  gem.homepage = 'https://github.com/npfedwards/git-deploy#readme'
  gem.license  = 'MIT'

  gem.files = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*', 'MAINTAINERS.md', 'CONTRIBUTING.md', 'ROADMAP.md']
end
