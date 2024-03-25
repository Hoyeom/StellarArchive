using System;

public class AccessCondition : IComparable<AccessCondition>
{
    private readonly int _priority;
    private readonly Func<bool> _conditionEvaluator;

    public AccessCondition(int priority, Func<bool> conditionEvaluator)
    {
        _priority = priority;
        _conditionEvaluator = conditionEvaluator;
    }
    
    public bool CanAccess()
    {
        if (_conditionEvaluator == null)
            return true;
        return _conditionEvaluator.Invoke();
    }

    public int CompareTo(AccessCondition other)
    {
        return _priority.CompareTo(other._priority);
    }
}