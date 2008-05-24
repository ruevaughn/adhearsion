# TODO : Remove me!

require File.dirname(__FILE__) + "/test_helper"

context "Referencing a component class in a dial plan context" do
  include CallContextComponentTestHelpers
  
  test "the component module constant should be available in the scope of a call context" do
    sample_component_class = new_componenet_class_named 'SampleComponent2'
    sample_component_class.add_call_context

    loader = load_dial_plan(<<-DIAL_PLAN)
      some_context {
        SampleComponent2
      }
    DIAL_PLAN
    
    flexmock(Adhearsion::DialPlan::Loader).should_receive(:load_dial_plan).and_return(loader)
    tested_call = Adhearsion::Call.new(nil, :context => :some_context)
    mock_config = flexmock 'a Configuration which communicates automatically_answer_incoming_calls properly',
                    :automatically_answer_incoming_calls => false
    flexmock(Adhearsion::Configuration).should_receive(:new).once.and_return mock_config
    Adhearsion::Configuration.configure
    
    the_following_code {
      handle(tested_call)
    }.should.not.raise
  end
  
  
  private
    def load_dial_plan(dial_plan_as_string)
      Adhearsion::DialPlan::Loader.load(dial_plan_as_string)
    end
    
    def handle(call)
      Adhearsion::DialPlan::Manager.handle(call)
    end
end

BEGIN {
  module CallContextComponentTestHelpers
    def new_componenet_class_named(component_name)
      component_namespace = Adhearsion::Components::ComponentModule.new('passed in component does not matter here')
      Adhearsion::Components::Component.prepare_component_class(component_namespace, component_name)
      component_namespace.const_get(component_name)
    end
  end
}