# string, number, boolean型の指定例
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
  name: "Max",
  age: 30,
};
このように明示的にオブジェクトの中身の型を指定することもできるが、ベストプラクティスとは言えない。型推論が働く場合、そちらに任せるのが良い。

# 配列の型指定
const foo = ["bar", "baz"]
のような配列に型を指定する場合、
const foo: string[] = ["bar", "baz"]
と型を指定する。

# Tuple型
配列と似ているが、要素の型と数を固定にする。例えば
role: [number, string]
と型指定を行った場合、要素の1つ目はnumber型の要素かつ、2つ目の要素はstring型でなければならない。roleに3つ目の要素は追加できず、追加しようとするとエラーが発生する。ただし、pushは許可されてしまうので注意。

# Enum型
TypeScript独自の型。複数の定数を定義するときに便利。
例えば、Roleという名前のenum型を定義する場合、

enum Role {}

として、中身を定義していく。

enum Role {
  ADMIN, // 0
  READ_ONLY, // 1
  AUTHOR, // 2
}
このように定義した場合、これらの定数には自動的に0からインクリメントした数値が割り当てられる。割り当てられる数値は上記の通り。

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

# Any型
TypeScriptの中で一番柔軟な型。どんな値でも入れることができる。ただし、この型を使うとTypeScriptの恩恵を得られないため、できるだけ使わないほうがいい。

# Union型
例えばある関数の引数をnumber型とstring型にしたい場合、

function foobar(attr1: number | string, attr2: number | string) {
  ......
}
のように、型をパイプでつないで記述することで柔軟な型定義を実装できる。

# Literal型
型を厳密に指定する。例えば、

const number: 2.8;
と定義した場合、numberには2.8以外の値を代入することはできない。
Union型と組み合わせて使うこともでき、

const foo: "as-text" | "as-number"
とすると、fooには文字列のas-textかas-numberしか入らない型を定義することができる。関数の引数の文字列を明示的に指定したい場合などに便利。

# 型エイリアス
typeという文字列に続けて定義する。何度も繰り返し使うような型定義を使い回すのに便利。例えば、number型かstring型の型定義を型エイリアスで定義したい場合、

type Combinable = number | string;

と定義しておけば、以下Combinableと型指定することで繰り返し使うことができる。
function foobar (input1: Combinable, input2: Combinable) {
  ...
}

# void型
関数が何も返さないことを示す型。以下例

function printResult(num: number): void {
  console.log('Result: ' + num)
}
この関数は何もreturnしないので、戻り値はvoid型になる。型推論で定義されている場合がほとんどなので、明示的に示さなくても良いことがほとんど。

# function型
変数に代入する関数の型を明示的に指定することもできる。

function add(n1: number, n2: number) {
  return n1 + n2;
}

function printResult(num: number) {
  console.log("Result: " + num);
}

let combineValues: (a: number, b: number) => number;
combineValues = add; // 正しく動作する
combineValues = printResult // 関数の型が正しくないのでエラーになる
combineValues = 5; // number型を代入できないのでエラーになる

# function型とコールバック
function addAndHandle(n1: number, n2: number, cb: (num: number) => void) {
  const result = n1 + n2;
  cb(result);
}

addAndHandle(10, 20, (result) => {
  console.log(result);
});

# unknown型
typescriptはany型は型チェックしないが、unknown型は型をチェックするので、any型を使うよりは良い選択肢になる。

# never型
ある関数が戻り値を返すことが絶対にありえないときに使われる型。

function generateError(message: string, code: number): never {
  throw { message: message, errorCode: code };
}
この関数は明示的にnever型を指定しなければvoid型になるが、絶対に戻り値を返すことはないので、コードの品質という観点からnever型を明示的に指定した方が良い。