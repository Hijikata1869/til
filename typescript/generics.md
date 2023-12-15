# ジェネリック型
ジェネリック型とは、他の特定の型と結合された型。「汎用型」とも呼ばれる。「追加の型情報」を切り替えて汎用的に利用できる。
例１）Array<string>(他の型はstring)
例１）Array<number>(他の型はnumber)

// 配列のジェネリック型
const foobar: Array<string> = []; // foobar: string[]と一緒

// Promiseのジェネリック型。この場合、string型のデータを返すことを明示的に示すことができる。
const promise: Promise<string> = new Promise((resolve, reject) => {
  setTimeout(() => {
    resolve("終わりました！");
  }, 2000);
});

// 上のPromiseはstring型のデータを返すことをジェネリック型の型定義で示しているため、splitメソッドが使える。これが仮にtoLocaleStringなどのnumber型特有のメソッドを指定した場合、typescriptはエラーを表示する。
promise.then(data => {
  data.split(' ');
})

// 【ジェネリック(汎用)型とは】追加の型情報を提供できる型
// 【ジェネリック型の利用目的】TypeScriptにおける型安全性を高めることができる / 自動補完等の開発サポートを向上することができる



# Generic関数の作成
function merge(objA: object, objB: object) {
  return Object.assign(objA, objB);
}

const mergedObj = merge({ name: "Max" }, { age: 30 }); // {name: "Max", age: 30}

mergedObj.name // エラー
// nameプロパティが存在するにもかかわらずエラーになる。typescriptはこのオブジェクトの型をオブジェクトとしてしか認識していないから。型キャストで型をTypeScriptに伝えることもできるが非常に面倒。このようなときにジェネリック型が便利。

// mergeに追加する識別子は通常はType(型)から取って、Tからスタートする。任意のものを使うことができるし、一つだけでなくともいい。慣習的にはTからスタートし、アルファベット順に次はUになる。
// 下記の実装だとTypeScriptの型推論の結果は "function merge<T, U>(objA: T, objB: U): T & U" と交差型を返す型推論になる。
function merge<T, U>(objA: T, objB: U) {
  return Object.assign(objA, objB);
}

// mergedObjにカーソルを当てると const mergedObj: { name: string; } & { age: number; }と、TypeScriptが認識している。
const mergedObj = merge({ name: "Max" }, { age: 30 });

// なぜ最初のobject型ではダメだったのか？それは、object型がとても曖昧な型だから。objectであればなんでも良く、typescriptに有用な情報を提供していないから。一方でジェネリックの記述だと2つのパラメータが異なる可能性のある型だということを伝えることができる。それにより異なった型のオブジェクトを受け取り、その交差型を返すということをTypeScriptが理解することができる。TとUが同じ型であっても問題はない。

const mergedObj = merge({ name: "Max", hobbies: ["sports"] }, { age: 30 }); // こういった定義もできる。



# 制約付きのGeneric型
// オブジェクトの中身の型はわからないが、とにかくobjectであることを示したい場合はextendsキーワードを使って制約を追加することができる。
function merge<T extends object, U extends object>(objA: T, objB: U) {
  return Object.assign(objA, objB);
}

const mergedObj = merge({ name: "Max" }, 30); // エラー
const mergedObj = merge({ name: "Max" }, { age: 30 }); // 正しく動作する

extendsの後にはどんな方でも参照できる。string, numberはもちろんPersonといった独自の型や、string | numberなどのユニオン型でも良い。とても柔軟。



# もう一つのGeneric関数
interface Lengthy {
  length: number;
}

function countAndDescribe<T extends Lengthy>(element: T): [T, string] {
  let descriptionText = "値がありません。";
  if (element.length > 0) {
    descriptionText = "値は" + element.length + "個です。";
  }
  return [element, descriptionText];
}
Lengthyインターフェースを実装することで、Tの型がなんであれlengthプロパティを持っていることが保証される。Lengthyがなければlengthの部分でエラーが出る。number型はlengthプロパティを持っていないため、countAndDescribeの引数にnumber型を入れようとするとエラーになる。