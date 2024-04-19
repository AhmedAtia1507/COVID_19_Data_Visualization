classdef covid_database < handle
    properties
        CountryNames
        StateNames
        Dates
        DatesMonthsYears
        CumulativeCasesDeaths
        CumulativeCases
        CumulativeDeaths
        DailyCases
        DailyDeaths
    end
    methods
        function obj = covid_database(covid_data)
            element_size = size(covid_data);
            obj.CountryNames = cell((element_size(1) - 1), 1);
            obj.StateNames = cell((element_size(1) - 1), 1);
            get_countries_states(obj,covid_data);
            find_dates(obj,covid_data);
            Cases = covid_data(2:element_size(1),3:element_size(2));
            obj.CumulativeCases = zeros(size(Cases));
            obj.CumulativeDeaths = zeros(size(Cases));
            obj.DailyCases = zeros(size(Cases));
            obj.DailyDeaths = zeros(size(Cases));
            find_cumulative_cases_deaths(obj, covid_data);
            find_daily_cases_deaths(obj);
            find_global_cases_deaths(obj,covid_data);
            obj.DatesMonthsYears = string([1:90:(element_size(2) - 2),1]);
            find_months_years(obj);
        end
        function obj = get_countries_states(obj,covid_data)
            countries = covid_data(2:end,1); states = covid_data(2:end,2); len = size(countries,1);
            obj.CountryNames{1} = 'Global';obj.StateNames{1} = "All";
            country_index = 2; state_index = 1;num_countries = 1;states_entry = 0;
            for index = 1: size(countries,1)
                if isequal(length(states{index}),0)
                    if(isequal(states_entry,1))
                        country_index = country_index + 1;
                        states_entry = 0;
                    end
                    state_index = 1;
                    obj.CountryNames{country_index} = countries{index};
                    obj.StateNames{country_index}(state_index) = "All";
                    country_index = country_index + 1; state_index = state_index + 1;
                    num_countries = num_countries + 1;
                else
                    if isequal(states_entry,0)
                        country_index = country_index - 1;
                        states_entry = 1;
                    end
                    obj.StateNames{country_index}(state_index) = string(states{index});
                    state_index = state_index + 1;
                end
            end
            obj.CountryNames(num_countries+1:len) = [];
            obj.StateNames(num_countries + 1:len) = [];
        end
        function obj = find_cumulative_cases_deaths(obj, covid_data)
            obj.CumulativeCasesDeaths = covid_data(2:end,3:end);
            for index_1 = 1:size(obj.CumulativeCasesDeaths,1)
                for index_2 = 1:size(obj.CumulativeCasesDeaths,2)
                    obj.CumulativeCases(index_1,index_2) = obj.CumulativeCasesDeaths{index_1,index_2}(1);
                    obj.CumulativeDeaths(index_1,index_2) = obj.CumulativeCasesDeaths{index_1,index_2}(2);
                end
            end
        end
        function obj = find_daily_cases_deaths(obj)
            length_t = size(obj.CumulativeCases);
            obj.DailyCases(:,1) = obj.CumulativeCases(:,1);
            obj.DailyDeaths(:,1) = obj.CumulativeDeaths(:,1);
            for index = 2:length_t(2)
                previous_sum_cases = sum(obj.DailyCases(:,1:(index-1)),2);
                previous_sum_deaths = sum(obj.DailyDeaths(:,1:(index-1)),2);
                obj.DailyCases(:,index) = obj.CumulativeCases(:,index) - previous_sum_cases;
                obj.DailyDeaths(:,index) = obj.CumulativeDeaths(:,index) - previous_sum_deaths; 
            end
        end
        function obj = find_dates(obj, covid_data)
            dates = covid_data(1,3:end); obj.Dates = zeros(1,length(dates)); obj.Dates = string(obj.Dates);
            for index = 1:length(dates)
                obj.Dates(index) = string(dates{index});
            end
        end
        function obj = find_global_cases_deaths(obj,covid_data)
            sizeOfData = size(covid_data);
            Global_Cumulative_Cases = zeros(1,size(obj.CumulativeCases,2));
            Global_Cumulative_Deaths = zeros(1,size(obj.CumulativeDeaths,2));
            Global_Daily_Cases = zeros(1,size(obj.DailyCases,2));
            Global_Daily_Deaths = zeros(1,size(obj.DailyDeaths,2));
            Data_indices = []; ii = 1;
            for index = 2:sizeOfData(1)
                if strcmp(covid_data{index,2},'')
                    Data_indices(ii) = index - 1;
                    ii = ii + 1;
                end
            end
            Data_indices(ii:end) = [];
            for index = Data_indices
                Global_Cumulative_Cases = Global_Cumulative_Cases + obj.CumulativeCases(index,:);
                Global_Cumulative_Deaths = Global_Cumulative_Deaths + obj.CumulativeDeaths(index,:);
                Global_Daily_Cases = Global_Cumulative_Cases + obj.DailyCases(index,:);
                Global_Daily_Deaths = Global_Cumulative_Cases + obj.DailyDeaths(index,:);
            end
            obj.CumulativeCases = [Global_Cumulative_Cases;obj.CumulativeCases];
            obj.CumulativeDeaths = [Global_Cumulative_Deaths;obj.CumulativeDeaths];
            obj.DailyCases = [Global_Daily_Cases;obj.DailyCases];
            obj.DailyDeaths = [Global_Daily_Deaths;obj.DailyDeaths];
        end
        function obj = find_months_years(obj)
            ii = 1; index = 1;
            for index = 1:90:length(obj.Dates)
                if ~(isequal(obj.Dates{index}(2),'/'))
                    months = obj.Dates{index}(1:2);
                else
                    months = obj.Dates{index}(1);
                end
                obj.DatesMonthsYears(ii) = string([months obj.Dates{index}(end-2:end)]);
                ii = ii + 1;
            end
            if ~isequal(index,length(obj.Dates))
                if ~(isequal(obj.Dates{end}(2),'/'))
                    months = obj.Dates{end}(1:2);
                else
                    months = obj.Dates{end}(1);
                end
                obj.DatesMonthsYears(ii) = string([months obj.Dates{end}(end-2:end)]);
            end
        end
    end
end
            