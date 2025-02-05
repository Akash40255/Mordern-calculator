<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList, java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modern Calculator</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="min-h-screen bg-gradient-to-br from-purple-400 to-indigo-600 dark:from-gray-800 dark:to-gray-900 flex items-center justify-center p-4">
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-2xl w-full max-w-md overflow-hidden transition-all duration-500">
        <div class="p-6">
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Modern Calculator</h2>
                <button id="darkModeToggle" class="p-2 rounded-full bg-gray-200 dark:bg-gray-700">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-gray-800 dark:text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                    </svg>
                </button>
            </div>
            
            <form method="post" id="calculatorForm" class="space-y-4">
                <div class="flex space-x-2">
                    <input type="number" name="num1" id="num1" required class="w-full px-3 py-2 bg-gray-100 dark:bg-gray-700 border-2 border-transparent rounded-md focus:outline-none focus:border-purple-500 dark:text-white" placeholder="Number 1">
                    <select name="operation" id="operation" class="px-3 py-2 bg-gray-100 dark:bg-gray-700 border-2 border-transparent rounded-md focus:outline-none focus:border-purple-500 dark:text-white">
                        <option value="add">+</option>
                        <option value="subtract">-</option>
                        <option value="multiply">×</option>
                        <option value="divide">÷</option>
                    </select>
                    <input type="number" name="num2" id="num2" required class="w-full px-3 py-2 bg-gray-100 dark:bg-gray-700 border-2 border-transparent rounded-md focus:outline-none focus:border-purple-500 dark:text-white" placeholder="Number 2">
                </div>
                <button type="submit" class="w-full bg-purple-600 text-white py-2 rounded-md hover:bg-purple-700 transition duration-300">Calculate</button>
            </form>

            <div id="result" class="mt-4 text-center text-xl font-semibold text-gray-800 dark:text-white"></div>

            <div class="mt-8 perspective">
                <div class="flip-card">
                    <div class="flip-card-inner">
                        <div class="flip-card-front">
                            <h3 class="text-lg font-semibold mb-2 text-gray-800 dark:text-white">Calculation History</h3>
                            <ul id="history" class="space-y-2">
                                <%
                                    List<String> history = (List<String>) session.getAttribute("calculationHistory");
                                    if (history == null) {
                                        history = new ArrayList<>();
                                        session.setAttribute("calculationHistory", history);
                                    }

                                    if (request.getMethod().equals("POST")) {
                                        double num1 = Double.parseDouble(request.getParameter("num1"));
                                        double num2 = Double.parseDouble(request.getParameter("num2"));
                                        String operation = request.getParameter("operation");
                                        double result = 0;
                                        String operationSymbol = "";

                                        switch (operation) {
                                            case "add":
                                                result = num1 + num2;
                                                operationSymbol = "+";
                                                break;
                                            case "subtract":
                                                result = num1 - num2;
                                                operationSymbol = "-";
                                                break;
                                            case "multiply":
                                                result = num1 * num2;
                                                operationSymbol = "×";
                                                break;
                                            case "divide":
                                                if (num2 != 0) {
                                                    result = num1 / num2;
                                                    operationSymbol = "÷";
                                                } else {
                                                    out.println("<script>document.getElementById('result').innerHTML = 'Error: Division by zero!';</script>");
                                                    return;
                                                }
                                                break;
                                        }

                                        String calculation = String.format("%.2f %s %.2f = %.2f", num1, operationSymbol, num2, result);
                                        history.add(0, calculation); // Add to the beginning of the list
                                        if (history.size() > 5) {
                                            history.remove(history.size() - 1); // Keep only the last 5 calculations
                                        }

                                        out.println("<script>document.getElementById('result').innerHTML = 'Result: " + result + "';</script>");
                                    }

                                    for (String calc : history) {
                                        out.println("<li class='text-gray-600 dark:text-gray-300'>" + calc + "</li>");
                                    }
                                %>
                            </ul>
                        </div>
                        <div class="flip-card-back">
                            <h3 class="text-lg font-semibold mb-2 text-gray-800 dark:text-white">Operation Frequency</h3>
                            <canvas id="operationChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
        .flip-card {
            background-color: transparent;
            width: 100%;
            height: 200px;
            perspective: 1000px;
        }
        .flip-card-inner {
            position: relative;
            width: 100%;
            height: 100%;
            text-align: center;
            transition: transform 0.6s;
            transform-style: preserve-3d;
        }
        .flip-card:hover .flip-card-inner {
            transform: rotateY(180deg);
        }
        .flip-card-front, .flip-card-back {
            position: absolute;
            width: 100%;
            height: 100%;
            -webkit-backface-visibility: hidden;
            backface-visibility: hidden;
        }
        .flip-card-back {
            transform: rotateY(180deg);
        }
    </style>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('calculatorForm');
            const num1Input = document.getElementById('num1');
            const num2Input = document.getElementById('num2');
            const operationSelect = document.getElementById('operation');
            const darkModeToggle = document.getElementById('darkModeToggle');

            // Dark mode toggle
            darkModeToggle.addEventListener('click', () => {
                document.documentElement.classList.toggle('dark');
            });

            // Keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Enter' && !e.shiftKey) {
                    form.dispatchEvent(new Event('submit'));
                } else if (e.key === '+') {
                    operationSelect.value = 'add';
                } else if (e.key === '-') {
                    operationSelect.value = 'subtract';
                } else if (e.key === '*') {
                    operationSelect.value = 'multiply';
                } else if (e.key === '/') {
                    operationSelect.value = 'divide';
                }
            });

            // Focus management
            num1Input.focus();
            form.addEventListener('submit', function() {
                setTimeout(() => num1Input.focus(), 0);
            });

            // Chart
            const ctx = document.getElementById('operationChart').getContext('2d');
            const operationCounts = {
                'add': 0,
                'subtract': 0,
                'multiply': 0,
                'divide': 0
            };

            // Count operations from history
            document.querySelectorAll('#history li').forEach(li => {
                const text = li.textContent;
                if (text.includes('+')) operationCounts.add++;
                else if (text.includes('-')) operationCounts.subtract++;
                else if (text.includes('×')) operationCounts.multiply++;
                else if (text.includes('÷')) operationCounts.divide++;
            });

            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: ['Addition', 'Subtraction', 'Multiplication', 'Division'],
                    datasets: [{
                        label: 'Operation Frequency',
                        data: [operationCounts.add, operationCounts.subtract, operationCounts.multiply, operationCounts.divide],
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.8)',
                            'rgba(54, 162, 235, 0.8)',
                            'rgba(255, 206, 86, 0.8)',
                            'rgba(75, 192, 192, 0.8)'
                        ],
                        borderColor: [
                            'rgba(255, 99, 132, 1)',
                            'rgba(54, 162, 235, 1)',
                            'rgba(255, 206, 86, 1)',
                            'rgba(75, 192, 192, 1)'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                stepSize: 1
                            }
                        }
                    },
                    plugins: {
                        legend: {
                            display: false
                        }
                    }
                }
            });
        });
    </script>
</body>
</html>

ss