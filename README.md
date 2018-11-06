# VM-Portal

This rails app enables managing of VMs via VSphere

## Developer guide
1. Testing  
* To run the full test suite: `bundle exec rspec`.
* For fancier test running use option `-f doc` and specify
 what tests to run by `-e 'search keyword in test name'`.
2. Linting  
* Rubocop is installed, run `bundle exec rubocop` to find problems.
* Use `--auto-correct` to fix what can be fixed automatically.
