module AbilityTestHelper
  
  def stub_ability
    ability = Object.new
    ability.extend(::CanCan::Ability)
    allow(controller).to receive(:current_ability).and_return(ability)
    ability
  end
  
end