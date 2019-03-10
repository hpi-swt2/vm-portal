function withTextInInputDo(text, callback) {
    let input = document.createElement('input');
    let parent = document.body;
    input.value = text;
    parent.appendChild(input);
    callback(input);
    parent.removeChild(input);
}

function copy(e) {
    e.preventDefault();
    let copyText = document.getElementById('macAddress');
    withTextInInputDo(copyText.innerText, input => {
        input.select();
        document.execCommand("copy");
    });
}