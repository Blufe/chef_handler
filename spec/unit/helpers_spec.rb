# Author:: Kartik Cating-Subramanian (<ksubramanian@chef.io>)
# Copyright:: Copyright (c) 2015 Chef, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'
require_relative 'test_handler'

describe ChefHandler::Helpers do
  include ChefHandler::Helpers

  let(:handler) { A::B::C.new }
  let(:handler_class_name) { 'A::B::C' }
  let(:handler_type) { 'something' }
  let(:handler_method) { :something_handlers }
  let(:registered_handlers) { [] }

  describe 'when invoking register_handler' do
    it 'adds the provided handler to Chef::Config' do
      allow(Chef::Config).to receive(handler_method).and_return(registered_handlers)
      register_handler(handler_type, handler)
      expect(registered_handlers).to contain_exactly(handler)
    end
  end

  describe 'when invoking unregister_handler' do
    context 'with a previously registered class' do
      let(:registered_handlers) { [handler] }
      it 'removes the registered handler in Chef::Config' do
        allow(Chef::Config).to receive(handler_method).and_return(registered_handlers)
        unregister_handler(handler_type, handler_class_name)
        expect(registered_handlers).to contain_exactly()
      end
    end

    context 'with no previously registered class' do
      let(:registered_handlers) { ['foobar'] }
      it 'removes the registered handler in Chef::Config' do
        allow(Chef::Config).to receive(handler_method).and_return(registered_handlers)
        unregister_handler(handler_type, handler_class_name)
        expect(registered_handlers).to contain_exactly('foobar')
      end
    end
  end

  describe 'when invoking reload_class' do
    let(:file_path) { File.join(File.dirname(__FILE__), file_name) }
    context 'with a previously loaded class' do
      let(:file_name) { 'test_handler.rb' }

      it 'unloads the existing class successfully' do
        old_handler_class = handler.class
        new_handler_class = reload_class(old_handler_class.name, file_path)
        expect(old_handler_class.name).to eq(new_handler_class.name)
        expect(old_handler_class).not_to equal(new_handler_class)
      end
    end
    context 'with no previously loaded class' do
      let(:file_name) { 'test_handler1.rb' }
      let(:handler_class_name) { 'D::E::F' }

      it 'continues to load the new class successfully' do
        new_handler_class = reload_class(handler_class_name, file_path)
        expect(new_handler_class.name).to eq(handler_class_name)
      end
    end
  end
end
