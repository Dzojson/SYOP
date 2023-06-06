function Get-AnalizyeWord{
    param (
        [Parameter(Mandatory = $true, Position = 0)] #parametr obowiązkowy ścieżki
        [string] $Path #zmienna typu string przechowywujący ścieżke
    )

    # Otwórz dokument Word
    $wordObejct = New-Object -ComObject Word.Application
    $wordObejct.Visible = $true
    $document = $wordObejct.Documents.Open($Path)

    #analiza słów w dokumencie
    $words = $document.Words | Where-Object { $_.Text -match '\b\w+\b' }
    $wordsCount = $words.Count
    Write-Host("Ilosc slow w dokumencie: " + $wordsCount)

    #liczenie średnią długość słów
    $letterCount = 0
    foreach($w in $words){
        $letterCount += $w.Text.Length
    }
    $avgLettersPerWord = $letterCount/$wordsCount
    Write-Host("srednia znakow na slowo: " + $avgLettersPerWord)

    #sprawdzanie ile jest krótszych i dłuższych od średniej
    $wordsAboveAvg = 0
    $wordsUnderAvg = 0
    foreach($w in $words){
        if($w.Text.Length -lt $avgLettersPerWord){
            $wordsUnderAvg += 1
        }else{
            $wordsAboveAvg += 1
        }
    }
    Write-Host("Ilosc slow krotszych niz srednia: " + $wordsUnderAvg + " slowa dluzsze niz srendia: " + $wordsAboveAvg)

    #szukanie najdłuższego słowa
    $longestWord = $null
    $longestWordLength = 0
    foreach($w in $words){
        if($null -eq $longestWord){
            $longestWordLength = $w.Text.Length
            $longestWord = $w
        }
        elseif ($longestWordLength -lt $w.Text.Length) {
            $longestWord = $w
            $longestWordLength = $w.Text.Length
        }
    }
    Write-Host("najdluzsze slowo: " + $longestWord.Text + "o dlugosci: " + $longestWordLength)

    #szukanie najczęściej występującego słowa
    $mostWordCounts = @{}
    foreach ($w in $words) {
        if ($mostWordCounts.ContainsKey($w.Text)) {
            $mostWordCounts[$w.Text] += 1
        } else {
            $mostWordCounts[$w.Text] = 1
        }
    }
    $sortedWords = ($mostWordCounts.GetEnumerator() | Sort-Object -Property Value -Descending)
    Write-Host("Najczesciej wystepujace slowo: " +$sortedWords[0].Name + " w ilosci: " + $sortedWords[0].Value)

    #Analiza zdań w dokumencie, ilość zdań
    $sentencesCount = $document.Sentences.Count
    Write-Host( "Ilosc zdan w dokumencie: " + $sentencesCount)

    #szukanie najdłuższych zdań
    $sentencesTxt = $document.Sentences | Select-Object -Expand Text

    $longestSentences = @()
    $longestSentenceLenght = 0
    foreach ($sentence in $sentencesTxt) {
        $trimSentence = $sentence.Trim()
        $words = $trimSentence -split '\s+'

        if ($longestSentences.Length -eq 0) {
            $longestSentences += $sentence
            $longestSentenceLenght = $words.Count
        }
        elseif($words.Count -gt $longestSentenceLenght) {
            $longestSentences = @()
            $longestSentences += $sentence
            $longestSentenceLenght = $words.Count
        }
        elseif($words.Count -eq $longestSentenceLenght){
            $longestSentences += $sentence
        }
    }
    Write-Host("Najdluzsze zdanie posiada: " + $longestSentenceLenght + ". Zdan o tej dlugosci jest: " + $longestSentences.Length)
    Write-Host("Sa to zdania: ")
    foreach($s in $longestSentences){
        Write-Host($s)
    }

    #szukanie najkrótszych zdań
    $shortestSentences = @()
    $shortestSentencesLenght = 0
    foreach ($sentence in $sentencesTxt) {
        $trimSentence = $sentence.Trim()
        $words = $trimSentence -split '\s+'

        if ($shortestSentences.Length -eq 0) {
            $shortestSentences += $sentence
            $shortestSentencesLenght = $words.Count
        }
        elseif($words.Count -lt $shortestSentencesLenght) {
            $shortestSentences = @()
            $shortestSentences += $sentence
            $shortestSentencesLenght = $words.Count
        }
        elseif($words.Count -eq $shortestSentencesLenght){
            $shortestSentences += $sentence
        }
    }
    Write-Host("Najkrotsze zdanie posiada: " + $shortestSentencesLenght + ". Zdan o tej dlugosci jest: " + $shortestSentences.Length)
    Write-Host("Sa to zdania: ")
    foreach($s in $shortestSentences){
        Write-Host($s)
    }
    #średnia ilość słów na zdanie
    $avgWordsPerSentence = $wordsCount /$sentencesCount
    Write-Host("Srednia ilosc slow na zdanie: " + $avgWordsPerSentence)
    
    # Zamknij dokument i zwolnij zasoby
    $document.Close()
    $wordObejct.Quit()

    #utworzenie wykresu
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Windows.Forms.DataVisualization

    $Chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
    $Chart.Width = 500
    $Chart.Height = 400
    $Chart.Left = 40

    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $Chart.ChartAreas.Add($ChartArea)

    $WordsChart = @{"Ilosc slow krotszych niz srednia" = $wordsUnderAvg; "Ilosc slow dluzszych niz srednia" = $wordsAboveAvg}

    $Chart.Series.Add("Data")
    $Chart.Series["Data"].Points.DataBindXY($WordsChart.Keys,$WordsChart.Values)

    $Form = New-Object System.Windows.Forms.Form
    $Form.Width = 600
    $Form.Height = 600
    $Form.Controls.Add($Chart)

    $Chart.Titles.Add("Wykaz dlugosci slow")
    $ChartArea.AxisY.Title = "ilosc znakow"
    $Form.ShowDialog()

}
Get-AnalizyeWord -Path D:\Studia\SEM7\syop\LoremIpsum.docx #wywołanie funkcji