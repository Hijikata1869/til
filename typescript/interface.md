# インターフェース
// インターフェースとは、オブジェクトがどんな形であるかを定義するもの。オブジェクトの構造の定義のために使用できる。
// インターフェースはコンパイル時にコードをチェックするためのもので、javascriptには出力されない
// Personというinterfaceを定義
interface Person {
  name: string;
  age: number;

  greet(phrase: string): void;
}

let user1: Person;

// user1はPersonのinterfaceにのっとった型かどうかチェックされる。型通りでないとエラーになる。
user1 = {
  name: "Max",
  age: 30,
  greet(phrase: string) {
    console.log(phrase + " " + this.name);
  },
};

user1.greet("Hello I am"); // Hello I am Max



# クラスでのインターフェースの実装
// interfaceはクラスに実装(implements)することもできる
interface Greetable {
  name: string;

  greet(phrase: string): void;
}

// ここではGreetableインターフェースの構造、つまりGreetableインターフェースで定義した型通りのプロパティやメソッドを持たせないとエラーになる。
// ただし、Greetableインターフェースに存在しないプロパティを追加することは可能
// また、クラスの継承と違い、インターフェースは複数実装できる
class Person implements Greetable {
  name: string;
  age = 30;

  constructor(n: string) {
    this.name = n;
  }

  greet(phrase: string) {
    console.log(phrase + " " + this.name);
  }
}

let user1: Greetable;

// user1はGreetable型だが、PersonクラスはGreetableインターフェースを実装しているためエラーにはならない
user1 = new Person("Max");

user1.greet("Hello I am"); // Hello I am Max
console.log(user1); // Person {age: 30, name: 'Max'}



# 読み取り専用のインターフェースプロパティ
クラスと同様、プロパティ名の前にreadonlyをつけることで初期化の際に一度だけ定義されることを強制できる。
interface Greetable {
  readonly name: string;

  greet(phrase: string): void;
}
このインターフェースを実装したクラスのnameプロパティは読み取り専用になる。



# インターフェースの拡張
インターフェースはクラス同様extendsキーワードを使って継承することができ、また、クラスと違い複数クラスを継承することができる。
interface Named {
  readonly name: string;
}

interface Greetable extends Named {
  greet(phrase: string): void;
}

// GreetableはNamedインターフェースを継承しているため、Personオブジェクトにnameプロパティを定義しないとエラーになる
class Person implements Greetable {
  name: string;
  age = 30;

  constructor(n: string) {
    this.name = n;
  }

  greet(phrase: string) {
    console.log(phrase + " " + this.name);
  }
}



# 関数型としてのインターフェース
// type AddFn = (a: number, b:number) => number;
// 上はFunction型、下はインターフェースによる関数の型定義
interface AddFn {
  (a: number, b: number): number;
}

let add: AddFn;

add = (n1: number, n2: number) => {
  return n1 + n2;
};



# 任意のパラメータ＆プロパティ
プロパティの後ろに ? をつけることで、そのプロパティがあってもなくてもいい、フレキシブルなプロパティを設定することができる。
interface Named {
  readonly name: string;
  outputName?: string;
}
こうすると、nameプロパティは必須だが、outputNameプロパティは必須ではないというインターフェースを定義することができる。