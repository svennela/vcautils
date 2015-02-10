# RaaSCLI, a tool that allows you to interact with a DRaaS subscription�
## Massimo Re Ferre' [www.it20.info](http://www.it20.info)

This tool has been developed mostly as a personal exercise. 

It allows users with a proper vCloud Air DR subscription to interact with the
service programmatically. 

Once installed (see below), users can call the RaaSCLI command line. It accepts
a number of different 
inputs. Just run `RaaSCLI` to have hints on usage.

This is the output on my laptop:

```shell
Usage: ./RaaSCLI operation [option1] [option2]

operations: peers|replications|testfailover[or test]|testcleanup[or cleanuptest]|failover[or recovery]

e.g. ./RaaSCLI peers
e.g. ./RaaSCLI replications ALL
e.g. ./RaaSCLI replications <VM name>
e.g. ./RaaSCLI testfailover [or test] <VM name>
e.g. ./RaaSCLI testfailover [or test] ALL
e.g. ./RaaSCLI testcleanup [or cleanuptest] <VM name>
e.g. ./RaaSCLI testcleanup [or cleanuptest] cleanuptest ALL
e.g. ./RaaSCLI failover [or recovery] <VM name>
e.g. ./RaaSCLI failover [or recovery] recovery ALL
```

#### Important:�the program requires a file called RaaSCLI.yml in the working dir

The file contains the parameters to connect to the DR VPC you want to interact
with. 

The format of the file MUST be as follows: 

```yaml
:username: email@domain@OrgName
:password: password
:site: https://vcd-url
```

You can get those values from the vCloud Air portal pointing to the DR VPC. If
this file is not in the working directory
(or the values are not correct) the program will abort. 


Use cases: 

- interacting with the service via CLI manually

- leveraging the CLI from some sort of higher level automation and
orchestration tools (e.g. vCO or SRM).

More in general, the program is structured to have a "RaaScore" module that
wraps the most common DR REST APIs. 
I try to refrain calling it a "DR SDK" but, done right, it could probably be
something like that. There is then a "RaaSmain" module that consumes
constructs in RaaScore and manage the user interaction. RaaSCLI is nothing more
than a CLI wrapper around RaaScore.

The idea is that one could take RaaScore and build (e.g.) a Sinatra application
on top of it. 


Known limitations (ver 0.0.5):

- I have only tested the tool with very few VMs. It is only supposed to work
with up to 25 VMs 
because I am not paging through the 25 defaults entry per pages in the REST
queries I run (e.g. GET replications)

- At the moment the `failover ALL` / `testfailover ALL` and / `testcleanup ALL` runs
sequentially on all the VMs per the order 
of the response against the REST APIs. In other words the VMs will failover /
testfailover / cleanup in an unforced order.
I am evaluating creating a better logic on the order against which we run those
commands (e.g. leveraging tags). Feedbacks are welcome.


Setup:

I have tested the program with Ruby 1.9.3. I haven't tested it with any other
Ruby version. 

if you are using Ruby already and are familiar with it, getting the program
setup could be as easy as running: 

`gem install RaaS`

If you are new to Ruby, I have tested these steps: http://tecadmin.net/install-ruby-1-9-3-or-multiple-ruby-verson-on-centos-6-3-using-rvm/

on a CentOS 6.4 64 bit VM on vCloud Air and they worked just fine. 

At the end, you still need to install the CLI by running `gem install RaaS`.


## Warning: 

Please use the tool at your own risk. There are some commands (e.g. `RaaSCLI
peers` or `RaaSCLI replications ALL`) that are harmless 
as they are mostly read-only. However there are other commands (e.g. `RaaSCLI
failover ALL`) that could be potentially dangerous in a production 
environment. Use with cautious. 


## License:

Apache Licensing version 2
# vcautils
