## 4/30
### 単項プラス

単項プラス演算子('+')はオペランドの前に置かれ、そのオペランドを評価し、それが数値以外の場合は数値に変換する。
例えば、文字列としての"2"が代入されたnumberという変数の前に+を置き、+numberとすることで、文字列としての"2"は、数値の2に変換される。

### オペランド
if文などの式の中で演算子の対象となっているものです。 つまり、演算子の左右にある変数や数字のことです。 そのため、オペランドは被演算子とも呼ばれます。

## 5/4
### for ... of
```:for ... ofの例
const array = ['a', 'b', 'c'];
for (const element of array) {
  console.log(element);
}
// Expected output: "a"
// Expected output: "b"
// Expected output: "c"
```
こんな感じで中身に対して繰り返し処理できる。

# 11/1
constで定義したオブジェクトや配列のプロパティは変更可能

# 11/2
## ファイルの関数を記述する位置について
プログラムの中で関数と関数を呼び出す側をどちらを先に記述すればいいのかについて、どちらから先に記述しても問題ありません。一般的には関数を先に定義しておき、そのあとで関数を呼び出すように記述されるケースが多いですが、関数の定義をあとに記述しても問題はありません。
（参考：https://www.javadrive.jp/javascript/function/index6.html）

# オブジェクトの分割代入におけるプロパティ名の上書き
const person = {
  nickname: 'Max',
  age: 30
}

// 通常は、代入する変数名はオブジェクトのプロパティ名である必要がある
const { nickname, age } = person;

// しかし、プロパティ名の後ろにコロンをつけることで、プロパティ名を上書きできる
const { nickname: userName, age } = person;

console.log(userName, age ) // 'Max', 30



# オブジェクトのプロパティへのアクセス方法
## ドット記法
.（ドット）を使ってプロパティにアクセスする記法です。
```
const obj = {};
obj.name = 'taka'; // objのプロパティをセット
obj.hello = function(){
    console.log(`Hello,${this.name}`);
}

console.log(obj.name); // taka
obj.hello(); // Hello,taka
```
オブジェクトとプロパティを.（ドット）で繋げることで、値の取得やメソッド実行ができます。

## ブラケット記法
[ ]（ブラケット）を使ってプロパティにアクセスする方法です。
```
const obj = {};
obj['name'] = 'taka'; // objのプロパティをセット
obj['hello'] = function(){
    console.log(`Hello,${this.name}`);
}

console.log(obj['name']); // taka
obj['hello'](); // Hello,taka
```
メソッドも[ ]の後に()を付けて関数を実行できます。

## ドット記法とブラケット記法の違い
ブラケット記法は、プロパティ名に変数を与えることができます。ドット記法ではできません。
```
const propName = 'name'; // 変数を用意

const obj = {};
obj[propName] = 'taka'; // プロパティ名に変数を使う
console.log(obj); // {name: "taka"}

obj.propName = "taka"; //ドット記法で変数を使ってもプロパティ名になる
console.log(obj); // {name: "taka",propName: "taka"}
```

そのため、ブラケット記法はループなど動的にプロパティ名を変更したい場合に便利です。
例えば、配列にキーを格納して、オブジェクトの中身を取得した時など。

```
const key = ['html','css','javascript'];
const obj = {
    html:'骨組み',
    css:'装飾',
    javascript:'動作'
}

key.forEach(function(key){
    let result = key + 'は、Webページの' + obj[key] + 'を作ります。'
    console.log(result);
});
```