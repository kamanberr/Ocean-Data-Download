function func_struct2nc_hycom(S, filename, coord_list)
%
%   Logic:
%     1. 변수의 k번째 차원 크기 == coord_list(k)의 크기 인지 확인 (Order Match)
%     2. 아니라면, coord_list 전체 중 크기가 같은 것이 있는지 확인 (Size Match)
%     3. 둘 다 아니면, 자동 이름 생성 (Auto Match)

    % 기존 파일 삭제
    if isfile(filename), delete(filename); end
    
    fields = fieldnames(S);
    
    % --- Step 1: 좌표 변수 정보 수집 및 저장 ---
    % coordInfo 구조체 배열에 이름과 길이 저장
    coordInfo = struct('name', {}, 'len', {});
    
    % fprintf('\n[Phase 1] Processing Coordinates (Dimensions)...\n');
    for i = 1:numel(coord_list)
        cName = coord_list(i);
        if isfield(S, cName)
            data = S.(cName);
            len = length(data);
            
            coordInfo(i).name = cName;
            coordInfo(i).len  = len;
            
            % 차원 정의 및 변수 저장
            nccreate(filename, cName, "Dimensions", {cName, len}, "Datatype", class(data));
            ncwrite(filename, cName, data);
            ncwriteatt(filename, cName, 'long_name', cName);
            
            % fprintf('  >> Defined Dimension [%d]: %s (Size: %d)\n', i, cName, len);
        else
            % warning('  !! Warning: There is no variable "%s" in the structure.', cName);
            coordInfo(i).name = "MISSING";
            coordInfo(i).len  = -1;
        end
    end
    
    % --- Step 2: 일반 변수 처리 및 차원 매칭 ---
    % fprintf('\n[Phase 2] Processing Variables & Matching Dimensions...\n');
    
    for i = 1:numel(fields)
        name = fields{i};
        % 좌표 변수는 이미 처리했으므로 건너뜀
        if ismember(name, coord_list), continue; end
        
        data = S.(name);
        
        % Data Type 처리
        attrs = struct("long_name", name);
        if isdatetime(data)
            data = posixtime(data);
            attrs.units = "seconds since 1970-01-01 00:00:00";
        elseif isstring(data) || ischar(data)
            data = char(string(data));
        end
        
        % 차원 크기 분석
        sz = size(data);
        % 끝부분의 singleton 차원 제거 (단, 1x1 스칼라는 유지)
        if numel(sz) > 2
            while numel(sz)>1 && sz(end)==1, sz(end) = []; end
        end
        
        dimCell = {};
        log_msg = sprintf('  VAR: %-6s | Size: %-12s | ', name, mat2str(sz));
        
        % 스칼라 처리
        if isscalar(data)
            dimCell = {};
            log_msg = [log_msg, 'Scalar (No Dim)'];
        else
            % 각 차원별 매칭 시도
            match_logs = strings(1, numel(sz));
            
            for d = 1:numel(sz)
                currLen = sz(d);
                matchedName = "";
                matchType = ""; 
                
                % [Logic A] 순서 기반 매칭 (Priority)
                % 현재 차원 순서(d)가 coord_list의 범위 내에 있고, 길이가 같은가?
                if d <= numel(coordInfo) && coordInfo(d).len == currLen
                    matchedName = coordInfo(d).name;
                    matchType = "Order";
                end
                
                % [Logic B] 크기 기반 매칭 (Fallback)
                % 순서 매칭 실패 시, 다른 좌표 중 크기가 같은 것이 있는가?
                if matchedName == ""
                    for c = 1:numel(coordInfo)
                        if coordInfo(c).len == currLen
                            matchedName = coordInfo(c).name;
                            matchType = "Size "; % Space for align
                            break; 
                        end
                    end
                end
                
                % [Logic C] 매칭 실패 (Auto generation)
                if matchedName == ""
                    matchedName = sprintf('%s_dim%d', name, d);
                    matchType = "Auto ";
                end
                
                % 결과 저장
                dimCell{end+1} = matchedName;
                dimCell{end+1} = currLen;
                
                match_logs(d) = sprintf("D%d->%s(%s)", d, matchedName, matchType);
            end
            log_msg = [log_msg, strjoin(match_logs, ", ")];
        end
        
        % 로그 출력 (사용자 고지)
        % fprintf('%s\n', log_msg);
        
        % NetCDF 생성 및 쓰기
        if ischar(data)
             nccreate(filename, name, "Dimensions", dimCell, "Datatype", "char");
        else
             nccreate(filename, name, "Dimensions", dimCell, "Datatype", class(data));
        end
        ncwrite(filename, name, data);
        
        % 속성 쓰기
        atn = fieldnames(attrs);
        for j = 1:numel(atn)
            ncwriteatt(filename, name, atn{j}, attrs.(atn{j}));
        end
    end
    % fprintf('------------------------------------------------------------\n');
end