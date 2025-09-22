TestClass = Class.new 'TestClass';

function TestClass:Constructor()
    self.name = "tezst" 
    self.age = 0
    self.gender = "homme" 
end

function TestClass:GetName()
    return self.name
end

function TestClass:SetName(name)
    self.name = name
end

function TestClass:SetAge(age)
    if (Value.IsNumber(age)) then
        self.age = age
    else 
        console.err("Invalid age")
    end
end 

function TestClass:SetGender(gender)
    self.gender = gender
end

function TestClass:GetAge()
    return self.age
end 