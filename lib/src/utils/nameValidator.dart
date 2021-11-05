
bool? nameValidator(String name, List<String> lista){

  if(name.isEmpty){
  return false;
  }

  for (var item in lista) {
    if(item == name)
    return false;
  }

  return true;
}