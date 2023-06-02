## 5/27
### 自己代入演算子
rubyで使われている"||="がわからなかったのでメモ。左辺がnilのときのみ代入することができるというもの。
```
name1 = nil
name2 = "foo"
name1 ||= name2
puts name1
// expected output: "foo"
```