function Instance:CreateInstance(instanceId)
    Tse('instance:joinInstance', instanceId)
end

function Instance:LeaveInstance()
    Tse('instance:leaveInstance')
end