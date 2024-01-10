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


# indexOf
```
indexOf() は Array インスタンスのメソッドで、引数に与えられた内容と同じ内容を持つ最初の配列要素の添字を返します。存在しない場合は -1 を返します。
const beasts = ['ant', 'bison', 'camel', 'duck', 'bison'];

console.log(beasts.indexOf('bison'));
// Expected output: 1
```


# splice
```
splice() は Array インスタンスのメソッドは、その場 (in-place) で既存の要素を取り除いたり、置き換えたり、新しい要素を追加したりすることで、配列の内容を変更します。

// 構文
splice(start, deleteCount)

// 引数
start
配列の変更を始める位置のゼロから始まるインデックスで、整数に変換されます。

deleteCount
配列の start の位置から取り除く古い要素の個数を示す整数です。
```


# HTMLTemplateElement: content プロパティ
HTMLTemplateElement.content プロパティは、<template> 要素のテンプレートの内容 (DocumentFragment) を返します。

## DocumentFragmentとは？
DocumentFragment インターフェイスは、親ノードを持たない最小限の文書オブジェクト（文書フラグメント）を表します。
これは Document の軽量版として使用され、標準の文書のようにノードで構成される文書構造の一区間を格納します。重要な違いは、文書フラグメントがアクティブな文書ツリー構造の一部ではないことです。フラグメントに対して変更を行っても、文書には影響しません。
→ 文書構造の一区間を格納しているに過ぎないから、documentより軽いですよってことかな？



# Document.importNode()
Document オブジェクトの importNode() メソッドは、後で現在の文書に挿入するために、他の文書から Node または DocumentFragment の複製を作成します。インポートされたノードは、まだ文書ツリーには含まれません。これを含めるには、 appendChild() や insertBefore() のような挿入メソッドを、現在の文書ツリーに存在するノードに対して呼び出す必要があります。document.adoptNode() とは異なり、元の文書から元のノードは削除されません。インポートされたノードは元のノードの複製です。
## 構文
importNode(externalNode);
importNode(externalNode, deep);
## 引数
externalNode
  現在の文書にインポートする、外部の Node または DocumentFragment です。

deep(省略可)
  論理値のフラグで、既定値は false であり、externalNode の DOM サブツリー全体をインポートするかどうかを制御します。
  deep が true に設定された場合、 externalNode およびその子孫全てが複製されます。
  deep が false に設定された場合、 externalNode のみがインポートされます — 新しいノードには子ノードはない状態になります。
## 例
```
const importedNode = document.importNode(
  this.templateElement.content,
  true
);
```



# Element: insertAdjacentElement() メソッド
insertAdjacentElement() は Element インターフェイスのメソッドで、呼び出された要素から相対的に指定された位置に、指定された要素ノードを挿入します。
## 構文
insertAdjacentElement(position, element)
## 引数
position
  文字列で、 targetElement の相対位置を表します。以下の何れかの文字列と一致する必要があります（大文字小文字の区別なし）。
  'beforebegin': targetElement 自体の前。
  'afterbegin': targetElement の直下、最初の子の前。
  'beforeend': targetElement の直下、最後の子の後。
  'afterend': targetElement 自体の後。

element
  ツリーに挿入する要素です。
## position の名前の視覚化
```HTML
<!-- beforebegin -->
<p>
  <!-- afterbegin -->
  foo
  <!-- beforeend -->
</p>
<!-- afterend -->
```