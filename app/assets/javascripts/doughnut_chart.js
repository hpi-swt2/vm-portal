function getChartColor(amount) {
  if(amount < 80) {
    return 'green';
  }
  if(amount < 90) {
    return 'yellow';
  }
  return 'red';
}

function getChartOptions(amount, title) {
  var color = getChartColor(amount);
  var backgroundColors = {
    green: 'rgba(0, 255, 0, 0.3)',
    yellow: 'rgba(255, 255, 0, 0.3)',
    red: 'rgba(255, 0, 0, 0.3)',
  };
  var borderColors = {
    green: 'rgba(0, 255, 0, 0.5)',
    yellow: 'rgba(255, 255, 0, 0.5)',
    red: 'rgba(255, 0, 0, 0.5)',
  };

  return {
      type: 'doughnut',
      data: {
        datasets: [{
          data: [amount, 100 - amount],
          backgroundColor: [
            backgroundColors[color],
            'rgba(255, 255, 255, 0.5)',
          ],
          borderColor: [
            borderColors[color],
            'rgba(0, 0, 0, 0.2)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        cutoutPercentage: 85,
        rotation: (3/4) * Math.PI,
        circumference: (3/2) * Math.PI,
        maintainAspectRatio: false,
        responsive: false,
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
    var amountNode = document.createElement("div");
    amountNode.innerText = amount.toString() + ' %';
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
