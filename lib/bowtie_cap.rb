################################################################################
#
# Copyright (C) 2007 Peter J Jones (pjones@pmade.com)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
################################################################################
#
# This file can be used with Capistrano 2.x to use Bowtie for
# restarting your servers after a deployment.
#
# You should set two variables for this to work:
#
# bowtie: The full path to the bowtie script, default will be
#         "bowtie", so bowtie needs to be in your PATH
#
# bowtie_cf: The full path to your bowtie configuration file. 
#            the default is "/etc/bowtie.conf"
################################################################################

# DRY up the bowtie tasks
def bowtie_invoke_command (bowtie_action)
  via   = :sudo if fetch(:use_sudo, false)
  via ||= :run
  
  bowtie      = fetch(:bowtie, "bowtie")
  bowtie_cf   = fetch(:bowtie_cf, "/etc/bowtie.conf")
  application = fetch(:application)
  bowtie_cmd  = "#{bowtie} -a #{bowtie_action} #{bowtie_cf} #{application}"
  
  invoke_command(bowtie_cmd, :via => via)
end

################################################################################
Capistrano::Configuration.instance.load do
  namespace :deploy do
    desc "Use Bowtie to restart the mongrel servers"
    task :restart, :roles => :app, :except => {:no_release => true} do
      bowtie_invoke_command("recycle")
    end

    desc "Use Bowtie to start the mongrel servers"
    task :start, :roles => :app do
      bowtie_invoke_command("start")
    end

    desc "Use Bowtie to stop the mongrel servers"
    task :stop, :roles => :app do
      bowtie_invoke_command("stop")
    end
  end
end