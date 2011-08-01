##
# Cookbook Name:: php
# Recipe:: pear
#
# Copyright 2011, Jose Diaz-Gonzalez
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

define :pear_module, :module => nil, :enable => true do
  
  include_recipe "php::pear"
  
  if params[:enable]
    execute "/usr/bin/pear install -a #{params[:module]}" do
      only_if "/bin/sh -c '! /usr/bin/pear info #{params[:module]} 2>&1 1>/dev/null"
    end
  end
  
end

define :pear_channel, :channel => nil, :enable => true do
  
  include_recipe "php::pear"
  
  if params[:enable]
    execute "/usr/bin/pear channel-discover #{params[:channel]}" do
      only_if "/bin/sh -c '! /usr/bin/pear/channel-info #{params[:channel]} 2>&1 1>/dev/null"
    end
  end
  
end
