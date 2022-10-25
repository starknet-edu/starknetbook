func main(){
    %{
        print(f"1. AP address is -----> {ap} -- {pc} -- {fp} y el valor de [AP - 1] es {memory[ap - 1]}")
    %}
    [ap] = 100, ap++;
    assert [ap-1] = 100;
    %{
        print(f"2. La dirección AP es -----> {ap} -- {pc} -- {fp} y el valor de [AP - 1] es {memory[ap - 1]}.")
    %}
    [ap] = 200, ap++;
    assert [ap-1] = 200;
    %{
        print(f"3. La dirección AP es -----> {ap} -- {pc} -- {fp} y el valor de [AP - 1] es {memory[ap - 1]}.")
    %}
    [ap] = 200, ap++;
    assert [ap-1] = 200;
    %{
        print(f"3. La dirección AP es -----> {ap} -- {pc} -- {fp} y el valor de [AP - 1] es {memory[ap - 1]}.")
    %}
    return();
}