
[CmdletBinding()]
param (
    [string]
    $IsoDate,

    [bool]
    $CalendarRound
)

class DistanceNumber {
    [int] $Days = 0

    DistanceNumber([int] $Days) {
        $this.Days = $Days
    }
}

class MayaNumber {
    [int] $Days = 0

    MayaNumber([int] $Days) {
        $this.Days = $Days
    }
}

class LongCountDate {
    [int[]] $Digits

    LongCountDate([int[]] $Digits) {
        $this.Digits = $Digits
    }

    LongCountDate([MayaNumber] $MayaNumber) {
        $Days = $MayaNumber.Days
        $CurrentWeight = 1
        $NextWeight = 20
        $Result = @()
        
        while($Days -ne 0) {
            $LowerPart = $Days % $NextWeight
            $Result += $LowerPart / $CurrentWeight

            $Days = $Days - $LowerPart
            $CurrentWeight = $NextWeight
            $NextWeight = ($NextWeight -eq 20) ? 360 : 20 * $NextWeight
        }
        $this.Digits = $Result
    }

    [string] StandardNotation() {
        $StringDigits = $this.Digits -as [string[]]
        [array]::Reverse($StringDigits)
        return $StringDigits -Join "."
    }

    [MayaNumber] MayaNumber() {
        $Weight = 1
        $Sum = 0
        foreach($Digit in $this.Digits) {
            $Sum += $Digit * $Weight
            $Weight = ($Weight -eq 20) ? 360 : 20 * $Weight
        }
        return [MayaNumber]::new($Sum)
    }
}

enum TzolkinDayName {
    Imix
    Ik
    Akbal
    Kan
    Chicchan
    Kimi
    Manik
    Lamat
    Muluk
    Ok
    Chuwen
    Eb
    Ben
    Ix
    Men
    Kib
    Kaban
    Etznab
    Kawak
    Ajaw
}

function Get-StandardName() {
    param (
        [TzolkinDayName] $DayName
    )

    $StandardNames = (
        "Imix", "Ik'", "Ak'b'al", "K'an",
        "Chicchan", "Kimi", "Manik'", "Lamat",
        "Muluk", "Ok", "Chuwen", "Eb'",
        "B'en", "Ix", "Men", "Kib'",
        "Kab'an", "Etz'nab'", "Kawak", "Ajaw"
    )
    return $StandardNames[$DayName]
}

class TzolkinDate {
    [ValidateRange(1,13)][int] $TrecendaDay = 1
    [TzolkinDayName] $DayName = [TzolkinDayName]::Imix

    TzolkinDate( [int] $TrecendaDay, [TzolkinDayName] $DayName) {
        $this.TrecendaDay = $TrecendaDay
        $this.DayName = $DayName
    }

    [string] StandardNotation() {
        return Get-StandardName($this.DayName)
    }

    [TzolkinDate] AddDays([int] $Days) {
        return [TzolkinDate]::new(
            1 + (($this.TrecendaDay - 1 + $Days) % 13),
            ($this.DayName + $Days) % 20
        )
    }
}

$PocoUinicDate = [DateTime]::ParseExact("0790-07-20", "yyyy-MM-dd", $null) # julian date 16 July 790
$Date = [DateTime]::ParseExact($IsoDate, "yyyy-MM-dd", $null)
$Delta = NEW-TIMESPAN –Start $PocoUinicDate –End $Date
Write-Output $Delta

$lc = [LongCountDate]::new((16, 13, 19, 17, 9))
$lc = [LongCountDate]::new([MayaNumber]::new(1412618))
Write-Output $lc.StandardNotation()
Write-Output $lc.MayaNumber()

$t = [TzolkinDate]::new(1, [TzolkinDayName]::Ajaw).AddDays(20)
Write-Output $t
Write-Output $(Get-StandardName([TzolkinDayName]::Akbal))


#poco_uinic_eclipse_long_count = [16, 13, 19, 17, 9]
#poco_uinic_eclipse_date = datetime.datetime(790, 7, 20) # julian date 16 July 790
#poco_uinic_eclipse_maya_number = MayaNumber.from_long_count_digits(poco_uinic_eclipse_long_count)
