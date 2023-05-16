## 4/30
### typescriptとは？
typescriptはjavascriptのスーパーセット（上位互換）。  
javascriptより簡潔で、より良いコードを書くことができるような新しい機能を使うことができる。


## 5/1
typescriptを使うことのメリットについて学んだ。メリットは数多く存在するが、特に重要なのが”型”の概念があることだろう。型の概念が具体的にどのように役立つかは昨日学んだので割愛。

## 5/2
typescriptの主要な型のひとつであるnumber型について学習。  
typescriptのファイルでエラーが出ていても、デフォルトではtscコマンドでjsにコンパイルされる。コードを書きながらコンパイルするまでもなくエラーに気が付くことができるのがtypescriptのいいところ。

## 5/3
javascriptでも一応型のチェックはできる。しかし、typescriptの方がより簡潔にコードを書くことができるし、コードを書いている途中にエラーに気がつくことができる。typescriptが役に立つのはコードを書いているとき。ランタイム上ではjavascriptが実行されるだけで、typescriptとして何かしているわけではない。  
他主要な型にboolean, string型がある。

## 5/4
typescriptはオブジェクトの型を自動で推論してくれる。しかし、自分で明示的に指定することもできる。  
オブジェクトの中身の型の明示的な指定はベストプラクティスではない。typescriptに自動で推論させる方が良い。  
any型はフレキシブルな型だと思うかもしれないが、typescriptの恩恵を得られないので、なるべく使うべきではない。  
その他Object, Array, Tuple, Enum, Union, Literal, function, voidという型についても学んだ。

### Tuple型
Tuple型は要素数を固定できる。  
foo: [2, 'author'];
この要素数、型で固定したい場合にTuple型は便利。
foo: [number, string];
とすれば良い。

### Enum型（列挙型とも呼ばれる）
定義方法  
```
enum Foo {
  ADMIN, READ_ONLY, AUTHOR
}  
```
このように定義した場合、それぞれの値には数値の値が割り当てられ、  
ADMIN: 0,  
READ_ONLY: 1,  
AUTHOR: 2  
となる。  
値を取り出すときにはRole.ADMINのように取り出せば良い。  
また、Enumの値には自分で値を割り当てることもできる。  
```
enum Role {
  ADMIN = 5
  READ_ONLY
  AUTHOR
}
```
このようにすると、自動的にインクリメントで値が割り振られるため、READ_ONLY = 6, AUTHOR = 7 となる。  
また、それぞれの定数には数値だけでなく文字列も割り当てることができる。したがって、
```
enum Role {
  ADMIN = 'ADMIN',
  READ_ONLY = 100,
  AUTHOR = 200,
}
```
といった定義も可能。

### Union型
例えば関数の引数としてnumber型かstring型かどちらかを受け取りたい、など、型に柔軟性を持たせたいときに使う。
```
// number型のみ受け取れる型定義
foo: number

// string型のみ受け取れる型定義
bar: string

// number型とstring型両方を受け取れる型定義
baz: number | string
```

### Literal型
厳密に型を指定したいときに便利。以下例。
```
// Literal型とUnion型の組み合わせの例
foo: 'as-number' | 'as-text'
// 例えばこのfooが関数の引数であった場合、as-numberとas-textという文字列どちらかしか受け取れない型となる。string型だと引数に何を渡せば良いかわからないが、明示的に何を渡したいか示したい時などに便利。
```

### 型エイリアス/カスタム型
型定義を再利用して使うことができる。何度も同じUnion型を書くのが面倒なときなどに便利。
```
type Foo = number | string;

function Bar(Baz: Foo) {
  ...
};
// このように一度型エイリアスを指定すればそれを定義以降の箇所で呼び出し、繰り返し使うことができる。
```

### 関数の戻り値の型
関数の戻り値はtypescriptが推測して返してくれるが、明示的に何も返さないことを伝えたい場合は、voidを指定する。

### 関数自体の型
typescriptにはFunction型という型がある。
```
// Funciton型の定義
let foo: Function
```
しかし、これだと関数なら何でも代入できてしまい、typescriptの恩恵が受けにくい。そこで、もう少し厳密に関数の型を定義することもできる。
```
// number型の引数2つを受け取り、number型の戻り値を返す関数の型指定の実装例
foo: (bar: number, baz: number) => number;
```

## 5/9
### unknown型
any型ではtypescriptは型チェックをしないが、unknown型であれば型チェックがされる。そのため、any型よりは良い選択肢になる。  
voidとneverは戻り値がない点では同じ。しかし、関数が終了するかどうかが異なる。voidは関数が最後まで実行される。neverは関数の処理が中断、もしくは永遠に続く続くことを意味する。そのため、戻り値がneverの関数が関数が最後まで到達できてしまう実装の場合、typescriptはコンパイルエラーを出す。

## 5/11
### watchモード
```
tsc ○○○.ts
```
とターミナルで入力することでファイルをコンパイルできるが、ファイルを変更して保存するたびにコンパイルしなければならない。そこで、
```
tsc ○○○.ts --wathc
// or
tsc ○○○.ts -w
```
とすることで、typescriptがこのファイルの変更を検知して自動でコンパイルしてくれるようになる。ただし、このやり方の場合、１ファイルしか感知できないというデメリットがある。

## 5/13
### アロー関数における型指定
引数が一つで、()を省略するときのアロー関数の型指定の仕方は以下。
```
const foo: (bar: string | number) => void = bar => {
  console.log(bar);
}
```

### 5/14
```
// デフォルト関数パラメータ
const foo = (bar: number, baz: number = 1) => {
  return bar + baz;
};
foo(2);
// expected output: 3

// スプレッドオペレータ
const array = ['foo', 'bar', 'baz'];
const newArray: string[] = [];
newArray.push(...array);
console.log(newArray);
// expected output: ['foo', 'bar', 'baz'];

// レストパラメータ
const add = (...numbers: number[]) => {
  return numbers.reduce((curResult, curValue) => {
    return curResult + curValue;
  }, 0);
};
const result = add(1, 2, 3, 4);
console.log(result);
// expected output: 10

// 分割代入
// 配列
const foo = ['bar', 'baz'];
const [bar, baz] = foo;
console.log(bar); // expected output: 'bar';
console.log(baz); // expected output: 'baz';
```