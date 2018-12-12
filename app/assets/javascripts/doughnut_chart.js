function getChartOptions(amount, title) {
    return {
      type: 'doughnut',
      data: {
        datasets: [{
          data: [amount, 100 - amount],
          backgroundColor: [
            'rgba(0, 255, 0, 0.3)',
            'rgba(255, 255, 255, 0.5)',
          ],
          borderColor: [
            'rgba(0, 255, 0, 0.5)',
            'rgba(0, 0, 0, 0.2)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        cutoutPercentage: 85,
        rotation: (3/4) * Math.PI,
        circumference: (3/2) * Math.PI,
        tooltips: {
          enabled: false
        },
        title: {
          display: true,
          padding: -6,
          fontSize: 24,
          text: title,
          position: 'bottom'
        },
        events: []
      }
    }
}

function makeHalfDoughnutChart(name, amount, description) {
    var canvas = document.getElementById(name);
    canvas.style.width = "150px";
    canvas.style.height = "150px";
    var amountNode = document.createElement("div");
    amountNode.innerText =  `${amount} %`;
    amountNode.classList.add("graphLabel");
    amountNode.classList.add("amount");
    canvas.parentNode.appendChild(amountNode);
    var descriptionNode = document.createElement("div");
    descriptionNode.classList.add("graphLabel");
    descriptionNode.classList.add("description");
    descriptionNode.innerText = description;
    canvas.parentNode.appendChild(descriptionNode);
    options = getChartOptions(amount, name);
    return new Chart(canvas, options) 
}

makeHalfDoughnutChart(null, null, null)
