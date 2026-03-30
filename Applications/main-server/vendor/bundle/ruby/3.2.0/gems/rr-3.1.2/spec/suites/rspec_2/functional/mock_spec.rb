require File.expand_path('../../spec_helper', __FILE__)

describe 'mock', is_mock: true do
  include MockDefinitionCreatorHelpers

  context 'against instance methods', method_type: :instance do
    include_context 'tests for a double definition creator method that supports mocking'
  end

  context 'against class methods', method_type: :class do
    include_context 'tests for a double definition creator method that supports mocking'
  end

  def double_definition_creator_for(object, &block)
    mock(object, &block)
  end
end
