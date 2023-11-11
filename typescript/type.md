# 型の指定例
function add(n1: number, n2: number, showResult: boolean, phrase: string) {
  const result = n1 + n2;
  if (showResult) {
    console.log(phrase + result);
  } else return result;
}

# オブジェクトの型指定
// const person: {
//   name: string;
//   age: number;
// }
const person = {
  name: "daichi",
  age: 29,
};
明示的にオブジェクトの中身の型を指定することもできるが、型推論が働く場合、そちらに任せるのが良い。

# 配列の型指定
const foo = ["bar", "baz"]
のような配列に型を指定する場合、
foo: string[] = ["bar", "baz"]
と型を指定する。

# Tuple型
配列と似ているが、要素の型と数を固定にする。例えば
role: [number, string]
と型指定を行った場合、要素の1つ目はnumber型の要素かつ、2つ目の要素はstring型でなければならない。roleに3つ目の要素は追加できず、追加しようとするとエラーが発生する。ただし、pushは許可されてしまうので注意。