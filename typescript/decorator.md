# クラスのデコレータ
デコレータは最終的にはただの関数。慣習的に大文字スタートで定義することが多い。デコレータを使用する時には、@関数名で記述する。
クラスに対するデコレータは引数を１つ受け取る。デコレータの対象となるものを受け取る。下の場合、受け取るものはコンストラクタ関数。
デコレータはクラスが作成されたときに実行される。インスタンス化のタイミングではない。デコレータはjavascriptがクラスの定義を見つけたときに実行される。クラスのオブジェクトを作成したときではない。
```
// Loggerデコレータ
function Logger(constructor: Function) {
  console.log("ログ出力中");
  console.log(constructor);  // class Person {
                                  constructor() {
                                    this.name = "Max";
                                    console.log("Personオブジェクトを作成中");
                                  }
                                }
                                // クラスは結局のところコンストラクタ関数のシンタックスシュガーであることがわかる。
  
}
// 引数としてコンストラクタ関数を受け取らなければならないのでLogger(constructor: Function)と定義しているが、引数で受け取ったものを使わない場合、Logger(_: Function)とアンダースコアで書くことにより、TypeScriptに引数は受け取るが、使わないということを伝えることができる。

@Logger // デコレータを使いたいクラスの前で、@をつけて呼び出す
class Person {
  name = "Max";

  constructor() {
    console.log("Personオブジェクトを作成中");
  }
}

const pers = new Person();
```


# デコレータファクトリ
デコレータファクトリは、デコレータを何かに割り当てるときにデコレータをカスタマイズできるようにするもの。
デコレータファクトリを使うと、任意の引数を必要な数だけ指定することができるようになる。つまり、デコレータ関数の中で使う値をカスタマイズできるようになる。
```
function Logger(logString: string) {
  return function (constructor: Function) {
    console.log(logString);
    console.log(constructor);
  };
}

@Logger("ログ出力中 - Person")
class Person {
  name = "Max";

  constructor() {
    console.log("Personオブジェクトを作成中");
  }
}
```

デコレータでDOM操作の例
```
function WithTemplate(template: string, hookId: string) {
  return function (constructor: any) {
    const hookEl = document.getElementById(hookId);
    const p = new constructor();
    if (hookEl) {
      hookEl.innerHTML = template;
      hookEl.querySelector("h1")!.textContent = p.name; // p.nameはこの場合 "Max"
    }
  };
}

@WithTemplate("<h1>Personオブジェクト</h1>", "app")
class Person {
  name = "Max";

  constructor() {
    console.log("Personオブジェクトを作成中");
  }
}

const pers = new Person();
// 画面にはh1タグで囲まれたMaxが表示される
```


# 複数のデコレータの追加
クラスには複数のデコレータを追加できる。
デコレータ関数の作成については上から順に実行される。しかし、デコレータ関数は下から上に実行される。
```
function Logger(logString: string) {
  console.log("LOGGER ファクトリ");
  return function (constructor: Function) {
    console.log(logString);
    console.log(constructor);
  };
}

function WithTemplate(template: string, hookId: string) {
  console.log("TEMPLATE ファクトリ");
  return function (constructor: any) {
    console.log("テンプレートを表示");
    const hookEl = document.getElementById(hookId);
    const p = new constructor();
    if (hookEl) {
      hookEl.innerHTML = template;
      hookEl.querySelector("h1")!.textContent = p.name;
    }
  };
}

@Logger("ログ出力中")
@WithTemplate("<h1>Personオブジェクト</h1>", "app")
class Person {
  name = "Max";

  constructor() {
    console.log("Personオブジェクトを作成中");
  }
}

const pers = new Person();
```
この場合コンソールには

LOGGER ファクトリ
TEMPLATE ファクトリ
テンプレートを表示
Personオブジェクトを作成中
ログ出力中
class Person {
    constructor() {
        this.name = "Max";
        console.log("Personオブジェクトを作成中");
    }
}
Personオブジェクトを作成中

の順で表示される。



# デコレータを追加できる場所
## プロパティ
デコレータはプロパティにも追加できる。プロパティのデコレータ関数は引数を２種類受け取る。1つ目の引数には、インスタンスのプロパティにデコレータを設定した場合、クラスのプロトタイプが渡される。インスタンスプロパティではなく、スタティックプロパティに設定した場合は、コンストラクタ関数が渡される。2つ目はプロパティの名前。
```
function Log(target: any, propertyName: string | symbol) {
  console.log("Property デコレータ");
  console.log(target, propertyName);
}

// 外から読み書きしてほしくないプロパティをアンダーバーで開始するのはただの慣習であるため、構文としての意味はない。(下の_price)
class Product {
  // プロパティに追加したデコレータ
  @Log
  title: string;
  private _price: number;

  set price(val: number) {
    if (val > 0) {
      this._price = val;
    } else {
      throw new Error("不正な価格です。 - 0以下は設定できません");
    }
  }

  constructor(t: string, p: number) {
    this.title = t;
    this._price = p;
  }

  getPriceWithTax(tax: number) {
    return this._price * (1 + tax);
  }
}
```

## アクセサー
デコレータはアクセサーにも追加できる。アクセサーのデコレータ関数は引数を３種類受け取る。1つ目はプロパティと同じ。2つ目はアクセサーの名前。3つ目はPropertyDescriptor(プロパティ記述子)。PropertyDescriptorは、プロパティをきめ細かく設定できるもの。
```
function Log2(target: any, name: string, descriptor: PropertyDescriptor) {
  console.log("Accessor デコレータ");
  console.log(target);
  console.log(name);
  console.log(descriptor);
}

class Product {
  title: string;
  private _price: number;

  // アクセサーに追加したデコレータ
  @Log2
  set price(val: number) {
    if (val > 0) {
      this._price = val;
    } else {
      throw new Error("不正な価格です。 - 0以下は設定できません");
    }
  }

  constructor(t: string, p: number) {
    this.title = t;
    this._price = p;
  }

  getPriceWithTax(tax: number) {
    return this._price * (1 + tax);
  }
}
```

## メソッド
アクセサーとメソッドの引数はほぼ同じ。ディスクリプターの中身が若干違う。
```
function Log3(
  target: any,
  name: string | symbol,
  descriptor: PropertyDescriptor
) {
  console.log("Method デコレータ");
  console.log(target);
  console.log(name);
  console.log(descriptor);
}

class Product {
  title: string;
  private _price: number;

  set price(val: number) {
    if (val > 0) {
      this._price = val;
    } else {
      throw new Error("不正な価格です。 - 0以下は設定できません");
    }
  }

  constructor(t: string, p: number) {
    this.title = t;
    this._price = p;
  }

  // メソッドに追加したデコレータ
  @Log3
  getPriceWithTax(tax: number) {
    return this._price * (1 + tax);
  }
}
```

## パラメータ
パラメータの直前につけて使うことができる。1つのパラメーターだけでなく、全てのパラメーターに使える。引数はtarget, name, position。
```
function Log4(target: any, name: string | symbol, position: number) {
  console.log("Parameter デコレータ");
  console.log(target);
  console.log(name);
  console.log(position);
}

class Product {
  @Log
  title: string;
  private _price: number;

  @Log2
  set price(val: number) {
    if (val > 0) {
      this._price = val;
    } else {
      throw new Error("不正な価格です。 - 0以下は設定できません");
    }
  }

  constructor(t: string, p: number) {
    this.title = t
    this._price = p;
  }

  getPriceWithTax(@Log4 tax: number) { // パラメータに追加したデコレータ
    return this._price * (1 + tax);
  }
}
```

# クラスデコレータによるクラスの変更
いくつかのデコレータは、値を返すことができる。例えばクラスデコレータや、メソッドデコレータ。クラスに追加されるデコレータはコンストラクタ関数を返すことができる。つまり、デコレータ関数が受け取ったコンストラクタ関数を別のものに置き換えることができる。これはコンストラクタ関数を返すか、シンプルにクラスを返す。そのクラスに名前をつける必要はなく、受け取ったコンストラクタ関数をextendsキーワードで継承することができる。
```typescript
function WithTemplate(template: string, hookId: string) {
  console.log("TEMPLATE ファクトリ");
  /*
    下のジェネリック型はクラスを受け取る必要がある。
  {new}はTypeScriptにこれはオブジェクトだが、newキーワードを使ってインスタンスを作れるもの、つまりコンストラクタ関数(クラス)であるということを伝えることができる。
  このnew関数は任意の数の引数を受け取ることができる。なので、レストパラメータを使っている。型はanyの配列。これによりコンストラクタ関数の引数に対して非常に柔軟な型を定義している。
  このnew関数はなんらかのオブジェクトを返す({})。この引数((...args: any[]))は新しいクラスのコンストラクタ関数に渡す必要がある。これによって全てのコンストラクタ関数の引数を受け取って、元のコンストラクタ関数に渡すことができる。ここではPersonクラスのインスタンス化をするときにPersonクラスに必要なコンストラクタの引数を渡せるようになる。
  new (...args: any[]): { name: string }とすることによって、nameプロパティを持つ新しいインスタンスを生成するコンストラクタを持つ任意の型Tということを定義している。つまり、新しいコンストラクタはstring型のnameプロパティを持つことが保証される。よって、関数の中でnameプロパティにアクセスすることができる。
   */
  return function <T extends { new (...args: any[]): { name: string } }>(
    originalConstructor: T
  ) {
    // 内側のデコレータ関数で、新しいクラスを返している。そのクラスにはオリジナルのクラスのメソッドやプロパティが引き継がれる。
    // 新しいクラスを返しているので、DOMへの表示ロジックは、クラスをインスタンス化した際に実行される。
    return class extends originalConstructor {
      constructor(..._: any[]) {
        // 継承したクラスでコンストラクタ関数を追加した場合には、super()を呼び出す必要がある。superを呼ぶとオリジナルのコンストラクタ関数が呼び出される。
        super();
        console.log("テンプレートを表示");
        const hookEl = document.getElementById(hookId);
        if (hookEl) {
          hookEl.innerHTML = template;
          hookEl.querySelector("h1")!.textContent = this.name;
        }
      }
    };
  };
}

@WithTemplate("<h1>Personオブジェクト</h1>", "app")
class Person {
  name = "Max";

  constructor() {
    console.log("Personオブジェクトを作成中");
  }
}

const pers = new Person();
// これにより、画面にこの場合、h1タグで囲まれたMaxが表示される。
```


# その他のデコレータの返却値
クラスの他には、メソッドデコレータと、アクセサーデコレータで値を返すことができる。この2つのデコレータは、propertyDescriptorを引数として受け取る。PropertyDescriptorは、プロパティを通常よりもよりきめ細かく設定できるもの。
```typescript
// メソッドのthisの参照先を常にPersonオブジェクトにバインドするためのデコレータ
function AutoBind(_: any, _2: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;
  const adjDescriptor: PropertyDescriptor = {
    configurable: true,
    enumerable: false,
    get() {
      // このthisはアクセスしようとしたプロパティを持つオブジェクトになる (プロパティを定義するために作成した記述子オブジェクトではない。この場合はPrinterクラスのオブジェクト)。インスタンス化した後も、このthisは上書きされない。
      const boundFn = originalMethod.bind(this);
      return boundFn;
    },
  };
  return adjDescriptor;
}

class Printer {
  message = "クリックしました！";

  @AutoBind
  showMessage() {
    console.log(this.message);
  }
}

const p = new Printer();

// Autobindデコレータを設定していない場合、p.showMessageのthisはbuttonタグを参照するため、コンソールにはundefinedが表示されてしまう。しかし、Autobindデコレータを設定するとthisの参照先がPersonオブジェクトになるため、コンソールには「クリックしました！」が表示される。
const button = document.querySelector("button")!;
button.addEventListener("click", p.showMessage);
```