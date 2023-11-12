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

# enum型
TypeScript独自の型。複数の定数を定義するときに便利。
例えば、Roleという名前のenum型を定義する場合、

enum Role {}

として、中身を定義していく。

enum Role {
  ADMIN, // 0
  READ_ONLY, // 1
  AUTHOR, // 2
}
このように定義した場合、これらの定数には自動的に数値が割り当てられる。割り当てられる数値は上記の通り。

enum Role {
  ADMIN = 5,
  READ_ONLY, // 6
  AUTHOR, // 7
}
このように定義した場合には、インクリメントした値が定義されるため、上記の数値が割り当てられる。

enum Role {
  ADMIN = 'AUTHOR', 
  READ_ONLY = 100, 
  AUTHOR = 200
}
上記のように個別に数値、文字列を割り当てることも可能。

値を取り出すときには

Role.ADMIN // 'AUTHOR'
Role.READ_ONLY // 100
Role.AUTHOR // 200
このようにして取り出す。if文などで使うこともできる。

# any型
TypeScriptの中で一番柔軟な型。どんな値でも入れることができる。ただし、この型を使うとTypeScriptの恩恵を得られないため、できるだけ使わないほうがいい。