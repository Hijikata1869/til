# 再レンダリングの条件
・ステートを変更した時
・propsの中身が変わった時
・親コンポーネントが再レンダリングされた場合、子コンポーネントも追従して再レンダリングされる

# mapなど繰り返し処理を行うときの注意点
ループ内でreturnしている一番親のタグにkeyを設定してあげる必要がある。 以下、理由。
Key は、どの要素が変更、追加もしくは削除されたのかを React が識別するのに役立ちます。配列内の項目に安定した識別性を与えるため、それぞれの項目に key を与えるべきです。兄弟間でその項目を一意に特定できるような文字列を key として選ぶのが最良の方法です。多くの場合、あなたのデータ内にある ID を key として使うことになるでしょう。（参考：https://ja.legacy.reactjs.org/docs/lists-and-keys.html）
仮装DOMとか関わることっぽい。

# useStateの配列にpushしても動かなかった。なぜか？
Reactではstateの値が変化した時にコンポーネントが再描画されます。
stateの値の変化を、Object.is() で判定しているとのことです。なので、pushやspliceでは前回と同じ値と判定されるそうです。そのため、再描画が起きないので、[...array, props.newValue]　などで値をコピーした新しい配列を生成してstateに保存すると再描画されます。(参考： https://qiita.com/naogify/items/cef4330858d0c677e71b)

# onClickに渡す関数の引数
onClick={fooBarFunction(attribute)}のように、onClick関数に引数を渡したくて()を記述するとその時点で実行されてしまう。実際にはクリックされた時にだけ実行したい。そのときは、onClick={() => fooBarFunction(attribute)}このように記述すれば良い。
