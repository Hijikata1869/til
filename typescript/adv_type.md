# 交差型
オブジェクトの交差型は２つの型のプロパティを持つ
type Admin = {
  name: string;
  privileges: string[];
};

type Employee = {
  name: string;
  startDate: Date;
};

type ElevatedEmployee = Admin & Employee;

// nameは共通。privileges, startDateの両方を定義しないとエラーになる
const e1: ElevatedEmployee = {
  name: "Max",
  privileges: ["create-server"],
  startDate: new Date(),
};

一方で、ユニオン型の交差型は交差した部分、つまり2つの型定義の共通部分だけが抜き出される
type Combinable = string | number;
type Numeric = number | boolean;

// 上2つの型定義に共通する型はnumber型なので、Universalはnumber型になる。Universalの型定義をした変数にstringやbooleanを割り当てようとするとエラーになる。
type Universal = Combinable & Numeric; // Universalはnumber型



# 型ガード
type Admin = {
  name: string;
  privileges: string[];
};

type Employee = {
  name: string;
  startDate: Date;
};

type ElevatedEmployee = Admin & Employee;

const e1: ElevatedEmployee = {
  name: "Max",
  privileges: ["create-server"],
  startDate: new Date(),
};

type Combinable = string | number;
type Numeric = number | boolean;

type Universal = Combinable & Numeric;

// return a + bだけだと引数がstring型かnumber型かわからないため、エラーになる。なので、typeofを用いて型を判定し、string型なら文字列の結合、number型ならそのまま足し算してreturnするようにしている。
function add(a: Combinable, b: Combinable) {
  if (typeof a === "string" || typeof b === "string") {
    return a.toString() + b.toString();
  }
  return a + b;
}

type UnknownEmployee = Employee | Admin;

// if文の中のin演算子は指定されたプロパティが指定されたオブジェクトにある場合にtrueを返す。nameプロパティ以外はEmployee型もしくはAdmin型のどちらかにしか存在しないため、in演算子で存在を確かめることで型ガードしている。
function printEmployeeInformation(emp: UnknownEmployee) {
  console.log(emp.name);
  if ("privileges" in emp) {
    console.log("privileges: " + emp.privileges);
  }
  if ("startDate" in emp) {
    console.log("StartDate: " + emp.startDate);
  }
}

class Car {
  drive() {
    console.log("運転中...");
  }
}

class Truck {
  drive() {
    console.log("トラックを運転中...");
  }

  loadCargo(amount: number) {
    console.log("荷物を載せています..." + amount);
  }
}

type Vehicle = Car | Truck;

const v1 = new Car();
const v2 = new Truck();

// if文の中のinstanceof演算子はあるオブジェクトが特定のクラスに属しているかどうかを確認できる演算子。loadCargoメソッドはTruckクラスにしか存在しないため、引数vehicleがTruckのインスタンスかどうか確かめてtrueの場合実行することで、型ガードを実現している。
function useVehicle(vehicle: Vehicle) {
  vehicle.drive();
  if (vehicle instanceof Truck) {
    vehicle.loadCargo(1000);
  }
}

useVehicle(v1);
useVehicle(v2);



# 判別可能なUnion型
Union型に含まれる全てのオブジェクト、またはインターフェースが共通のプロパティを持つことで、そのプロパティによってどのオブジェクトかを判別することができる。以下のように型ガードを実装する際にどのオブジェクトか調べることができる。判別可能なUnion型はオブジェクトのUnion型を使う時に便利。これはインターフェースに対しても動作する。

interface Bird {
  type: "bird";
  flyingSpeed: number;
}

interface Horse {
  type: "horse";
  runningSpeed: number;
}

type Animal = Bird | Horse;

function moveAnimal(animal: Animal) {
  let speed;
  switch (animal.type) {
    case "bird":
      speed = animal.flyingSpeed;
      break;
    case "horse":
      speed = animal.runningSpeed;
  }
  console.log("移動速度: " + speed);
}

moveAnimal({ type: "bird", flyingSpeed: 10 });



# 型キャスト
typescriptが型を知ることができない場合であっても、型キャストを使うことによってTypeScriptに型を伝えることができる。

// 以下のコードは同じ意味合いを持つ。プロジェクトによって、どちらかに統一した方がいい。
// 上は型を指定したいものの前につけるやり方。下は、asを用いて型を指定したいものの後につけるやり方。
// document.getElementById("user-input")の後に付いているエクスクラメーションマークはtypescriptに対して、エクスクラメーションマークの前にある式が絶対にnullではないと伝えるもの
const userInputElement = <HTMLInputElement>document.getElementById("user-input")!;
const userInputElement = document.getElementById(
  "user-input"
)! as HTMLInputElement;

userInputElement.value = "こんにちは";

// エクスクラメーションマークを使わずにif文を用いる場合
// 型キャストはnullではないこともtypescriptに伝えるものなので外しておく
const userInputElement = document.getElementById("user-input");

if (userInputElement) {
  // .valueの前まで()で囲む
  (userInputElement as HTMLInputElement).value = "こんにちは";
}



# インデックス型
インデックス型を用いる場合、オブジェクトのプロパティ名にどのような名前があるかやいくつのプロパティが必要か、ということをあらかじめ把握しておく必要はない。

// プロパティ名はstring型に変換できるものならなんでも良い。1などの数字であってもstring型に変換できるので使える。逆（string -> number）はできないので使えない。booleanも使えない。
interface ErrorContainer {
  [prop: string]: string;
}

// 型が守られていればプロパティはいくつでも追加することができる。
const errorBag: ErrorContainer = {
  email: "正しいメールアドレスではありません",
  username: "ユーザー名に記号を含めることはできません。",
};

# 関数オーバーロード
type Combinable = string | number;

function add(a: number, b: number): number;
function add(a: string, b: string): string;
function add(a: string, b: number): string;
function add(a: number, b: string): string;

// このadd関数のみ定義した場合、result.splitは使えない。typescriptはresultがstringであるかどうかわからないから（戻り値の型はCombinableになっている）。しかし、上でオーバーロードした関数を定義したことによって、引数a, bがstringの時には戻り値がstringであることが明確になるため、文字列のメソッドであるsplitが使える。
function add(a: Combinable, b: Combinable) {
  if (typeof a === "string" || typeof b === "string") {
    return a.toString() + b.toString();
  }
  return a + b;
}

const result = add("Hello", " TypeScript");
console.log(result.split(" "));



# null合体演算子
falsyな値を取得した場合にデフォルト値を設定したい場合、

const foo = '';

const bar = foo || 'baz';
console.log(bar) // baz
これで事足りる。しかし空文字をfalsy判定せず、nullとundefinedだけにしたい場合

const foo = '';
const bar = foo ?? 'baz';
console.log(bar) // '';
と??を使うことで実装できる。