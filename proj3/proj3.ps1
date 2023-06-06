function Get-Recepies{
    param (
        [Parameter(Mandatory = $true, Position = 0)] #parametr obowiązkowy ścieżki
        [string] $Path #zmienna typu string przechowywujący ścieżke
    )
    #wczytanie przepisów z pliku JSON
    $recipes = Get-Content -Raw D:\Studia\SEM7\syop\recpies.json | ConvertFrom-Json 

    #stworzenie tablic do przechowywania różnych "Difficulty", "Time", "Ingredients"
    $uniqueTimes = @()
    $uniqueIngredients = @()
    $uniqueDifficulty = @()
    $keys = @("Difficulty", "Time", "Ingredients")
    #słownik z wybranymi opcjami
    $recpieDic = [ordered]@{}
    foreach($key in $keys) {
        $recpieDic[$key] = $null
    }

    #wczytanie różnych "Difficulty", "Time"
    foreach($recipe in $recipes) {
        if($uniqueTimes -notcontains $recipe.Time) {
            $uniqueTimes += $recipe.Time
        }
        if($uniqueDifficulty -notcontains $recipe.Difficulty) {
            $uniqueDifficulty += $recipe.Difficulty
        }
    }

    #wczytanie różnych "Ingredients"
    foreach($recipe in $recipes) {
        $ingredientList = ($recipe.Ingredients -replace "lbs.","" -replace "lb.","" -replace "lyzki","" -replace "szklanka","" -replace "/","" -replace "szklanki","" -replace "szklanki","" -replace "lyzeczki""") -split "," #przefiltrowanie składników
        foreach ($ingredient in $ingredientList) {
            $ingredient = $ingredient.Trim() -replace "\d",""
            if ($uniqueIngredients -notcontains $ingredient) {
                $uniqueIngredients += $ingredient
            }
        }
    }
    $decisionDic = @{}#słownik z możliwymi opcjami

    #wypisanie ilości przepisów
    $recipesCount = $recipes.Count
    Write-Host("W ksiazce kucharskiej znajduje sie: " + $recipesCount + " przepisow.")

    #wybór poziomu trudności przepisu
    $DifficultyCount = $uniqueDifficulty.Count
    Write-Host("Do wyboru sa: " + $DifficultyCount + " poziomy trudnosci. Poziomy te to:")
    $c = 0
    foreach($d in $uniqueDifficulty){#utworzenie słownika z opcjami
        $c += 1
        Write-Host($c)-NoNewline
        Write-Host(". " + $d)
        $decisionDic[$c] = $d
    }
    while($true) {#wczytywanie od użytkownika
        $input = Read-Host "Wybierz poziom trudnosci przepisu"
        if([int]$input -ge 1 -and [int]$input -le $c) {
            Write-Host ("Wybrales poziom trudnosci " + $decisionDic[[int]$input]) 
            $recpieDic["Difficulty"] = $decisionDic[[int]$input] #przypisanie decyzji do słownika z wybranymi przepisami
            break
        } else {
            Write-Host "Nie ma takiego poziomu przepisu. Sprobuj ponownie"
        }
    }

    $decisionDic = @{}#słownik z możliwymi opcjami

    $TimeCount = $uniqueTimes.Count
    Write-Host("Do wyboru sa: " + $TimeCount + "czasy robienia dania. Czasy te to:")
    $c = 0
    foreach($t in $uniqueTimes){#utworzenie słownika z opcjami
        $c += 1
        Write-Host($c)-NoNewline
        Write-Host(". " + $t)
        $decisionDic[$c] = $t
    }
    while($true) {#wczytywanie od użytkownika
        $input = Read-Host "Wybierz czas trwania robienia przepisu"
        if([int]$input -ge 1 -and [int]$input -le $c) {
            Write-Host ("Wybrales czas trwania " + $decisionDic[[int]$input]) 
            $recpieDic["Time"] = $decisionDic[[int]$input]#przypisanie decyzji do słownika z wybranymi przepisami
            break
        } else {
            Write-Host "Nie ma takiej opcji. Sprobuj ponownie"
        }
    }

    $decisionDic = @{}#słownik z możliwymi opcjami
    while($true) {
        $input = Read-Host "Czy nie chcesz jakiegos skladnika? 1. Tak 2. Nie"
        if([int]$input -eq 1) {
            $c = 0
            foreach($i in $uniqueIngredients){
                $c += 1#utworzenie słownika z opcjami
                Write-Host($c)-NoNewline
                Write-Host(". " + $i)
                $decisionDic[$c] = $i
            }
            while($true) {#wczytywanie od użytkownika
                $input = Read-Host "Wybierz skladnik, ktorego nie chcesz"
                if([int]$input -ge 1 -and [int]$input -le $c) {
                    Write-Host ("Wybrales skladnik " + $decisionDic[[int]$input]) 
                    $rejedctedIngredients += $decisionDic[[int]$input]#przypisanie decyzji do słownika z wybranymi przepisami
                    $input = Read-Host "chcesz jeszcze odrzucic jakis skladnik? 1. Tak 2. Nie"
                    if([int]$input -eq 2){
                        break
                    }
                } else {
                    Write-Host "Nie ma takiej opcji. Sprobuj ponownie"
                }
                }
                $recpieDic["Ingredients"] = $rejedctedIngredients
            break
        } else {
            break
        }
    }

    Write-Host $recpieDic["Ingredients"]
    $noRecpie = $true
    foreach ($recipe in $recipes) {
        # Sprawdzanie czy przepis spełnia warunki
        if ($recipe.Difficulty -eq $recpieDic["Difficulty"] -and $recipe.Time -eq $recpieDic["Time"] -and ($null -eq $recpieDic["Ingredients"] -or $recipe.Ingredients -ne $recpieDic["Ingredients"])) {
            # Wypisanie przepisow
            Write-Host ($($recipe.Name))
            Write-Host ("Difficulty: " + $($recipe.Difficulty))
            Write-Host ("Time: " + $($recipe.Time))
            Write-Host ("Ingredients: " +$($recipe.Ingredients))
            $noRecpie = $false
        }
    }
    
    if($noRecpie -eq $true){
        Write-Host("Nie ma pzepisu spelniajacego Twoich warunkow")
    }


}
Get-Recepies -Path D:\Studia\SEM7\syop\recpies.json #wywołanie funkcji