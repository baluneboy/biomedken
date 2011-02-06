// How many different methods do you have that return datasets?
// You can do it using reflection, but if you only have a few options
// a cleaner way may bw to just use a case statememt:
DataSet myDataSet = null
switch(MethodName)
{
  case "GetFundingSources":
    myDataSet = dt.GetFundingSources();
    break;
  case "OtherMethod"
    myDataSet = dt.OtherMethod();
    break;
  ...
  default:
    throw new Exception("unexpected method name.");
}

//If you want to use reflection:
// Of course, you'll need to deal with exceptions
// like: if the method doesn't exist, doesn't return a DataSet, etc.
DataTable result = null;
Type t = dt.GetType();
MethodInfo mi = t.GetMethod(MethodName);
if (mi.ReturnType == typeof(DataTable))
{
      result = mi.Invoke(dt,null) As DataTable;
}